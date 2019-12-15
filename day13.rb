#!/usr/bin/env ruby
# frozen_string_literal: true

program = File.read('day13.txt').split(',').map(&:to_i)

class Intcode
  attr_accessor :program, :inputs, :outputs, :ip, :rb, :state

  def initialize(program, inputs = [], outputs = [], ip = 0, rb = 0)
    @program = program
    @inputs = inputs
    @outputs = outputs
    @ip = ip
    @rb = rb
    @state = :initialized
  end

  def run(final_state = :halted)
    step until @state == final_state
  end

  def step
    @state = :running
    opcode, modes = process_instruction

    case opcode
    when 1
      param1 = process_parameter(@program[@ip += 1], modes[0])
      param2 = process_parameter(@program[@ip += 1], modes[1])
      write_addr = @program[@ip += 1]
      write_addr += @rb if modes[2] == 2
      write(param1 + param2, write_addr)
    when 2
      param1 = process_parameter(@program[@ip += 1], modes[0])
      param2 = process_parameter(@program[@ip += 1], modes[1])
      write_addr = @program[@ip += 1]
      write_addr += @rb if modes[2] == 2
      write(param1 * param2, write_addr)
    when 3
      if @inputs.empty?
        @state = :awaiting_input
        return
      end

      write_addr = @program[@ip += 1]
      write_addr += @rb if modes[0] == 2
      write(@inputs.shift, write_addr)
    when 4
      param1 = process_parameter(@program[@ip += 1], modes[0])
      @outputs << param1
      @state = :output_available
    when 5
      param1 = process_parameter(@program[@ip += 1], modes[0])
      param2 = process_parameter(@program[@ip += 1], modes[1])
      @ip = param2 - 1 unless param1.zero?
    when 6
      param1 = process_parameter(@program[@ip += 1], modes[0])
      param2 = process_parameter(@program[@ip += 1], modes[1])
      @ip = param2 - 1 if param1.zero?
    when 7
      param1 = process_parameter(@program[@ip += 1], modes[0])
      param2 = process_parameter(@program[@ip += 1], modes[1])
      write_addr = @program[@ip += 1]
      write_addr += @rb if modes[2] == 2
      write(param1 < param2 ? 1 : 0, write_addr)
    when 8
      param1 = process_parameter(@program[@ip += 1], modes[0])
      param2 = process_parameter(@program[@ip += 1], modes[1])
      write_addr = @program[@ip += 1]
      write_addr += @rb if modes[2] == 2
      write(param1 == param2 ? 1 : 0, write_addr)
    when 9
      param1 = process_parameter(@program[@ip += 1], modes[0])
      @rb += param1
    when 99
      @state = :halted
      return
    else
      raise "Unknown opcode #{opcode} at address #{@ip}"
    end

    @ip += 1
  end

  def process_instruction
    s = format('%<value>05d', value: @program[@ip])
    opcode = s[-2..-1].to_i
    modes = s[0..2].chars.reverse.map(&:to_i)
    [opcode, modes]
  end

  def process_parameter(value, mode)
    case mode
    when 0 # position mode
      value < @program.size ? @program[value] : 0
    when 1 # immediate mode
      value
    when 2 # relative mode
      index = value + @rb
      index < @program.size ? @program[index] : 0
    else
      raise "Unknown parameter mode #{mode}"
    end
  end

  def write(value, position)
    @program += [0] * (position - @program.size + 1) if position >= @program.size
    @program[position] = value
  end
end

# Part 1

c = Intcode.new(program.dup)

n = 0
until c.state == :halted
  c.step until c.outputs.size == 3 || c.state == :halted
  tile = c.outputs.shift(3)
  n += 1 if tile[2] == 2
end

puts n

# Part 2

def draw_grid(grid)
  max_x = grid.keys.map { |x, _| x }.max
  max_y = grid.keys.map { |_, y| y }.max

  puts "SCORE: #{grid[[-1, 0]]}" if grid.key?([-1, 0])

  (0..max_y).each do |y|
    (0..max_x).each do |x|
      c = case grid[[x, y]]
          when 0
            ' '
          when 1
            "\e[36m#\e[0m"
          when 2
            "\e[31m*\e[0m"
          when 3
            "\e[32m=\e[0m"
          when 4
            "\e[33mo\e[0m"
          end
      print c
    end
    print "\n"
  end
end

def get_input(grid)
  ball_x, = grid.key(4)
  paddle_x, = grid.key(3)
  ball_x <=> paddle_x
end

p = program.dup
p[0] = 2
c = Intcode.new(p)

grid = {}
puts "\e[?25l"
until c.state == :halted
  c.step
  next unless c.outputs.size == 3 || [:halted, :awaiting_input].include?(c.state)
  break if c.state == :halted

  if c.outputs.size == 3
    x, y, tile_id = c.outputs.shift(3)
    grid[[x, y]] = tile_id
  end

  if c.state == :awaiting_input
    puts "\e[H\e[2J"
    draw_grid(grid)
    sleep(0.01)
    c.inputs << get_input(grid)
  end
end
puts "\e[0H\e[0J\e[?25h"

puts grid[[-1, 0]]
