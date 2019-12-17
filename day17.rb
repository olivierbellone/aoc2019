#!/usr/bin/env ruby
# frozen_string_literal: true

program = File.read('day17.txt').split(',').map(&:to_i)

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
c.run
map_string = c.outputs.map(&:chr).join
# puts map_string
map = map_string.lines.map { |line| line.strip.split('') }

intersections = []

map.each_with_index do |line, y|
  line.each_with_index do |char, x|
    next if x == 0 || y == 0 || x == line.size - 1 || y == map.size - 1
    next unless char == '#'
    next unless [[x, y - 1], [x, y + 1], [x - 1, y], [x + 1, y]].all? { |nx, ny| map[ny][nx] == '#' }

    intersections << [x, y]
  end
end

puts intersections.map { |x, y| x * y }.sum

# Part 2

new_program = program.dup
new_program[0] = 2
c = Intcode.new(new_program)

logic = '''A,A,B,C,B,C,B,C,B,A
R,6,L,12,R,6
L,12,R,6,L,8,L,12
R,12,L,10,L,10
n
'''
c.inputs += logic.split('').map(&:ord)
c.run

map_string = c.outputs[0..-2].map(&:chr).join
# puts map_string
puts c.outputs[-1]
