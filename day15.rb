#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

program = File.read('day15.txt').split(',').map(&:to_i)

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

def choose_direction(x, y, map, scores)
  neighbors = [[x, y - 1], [x, y + 1], [x - 1, y], [x + 1, y]]

  neighbors.each_with_index do |p, i|
    px, py = p
    return i + 1 unless map.key?([px, py])
  end

  lowest = Float::INFINITY
  direction = 0
  neighbors.each_with_index do |p, i|
    next if scores[p] > lowest
    lowest = scores[p]
    direction = i + 1
  end

  direction
end

def update_scores(scores, x, y, direction, output)
  if output != 1
    case direction
    when 1
      y -= 1
    when 2
      y += 1
    when 3
      x -= 1
    when 4
      x += 1
    end
  end

  scores[[x, y]] += 1
end

def update_map(map, x, y, direction, output)
  case direction
  when 1
    y -= 1
  when 2
    y += 1
  when 3
    x -= 1
  when 4
    x += 1
  end

  map[[x, y]] = output
end

def update_coords(x, y, direction)
  case direction
  when 1
    [x, y - 1]
  when 2
    [x, y + 1]
  when 3
    [x - 1, y]
  when 4
    [x + 1, y]
  end
end

def draw_map(map, cur_x, cur_y)
  puts "--------------- X = #{cur_x} Y = #{cur_y} ------------------"

  min_x = map.keys.map { |x, _| x }.min
  max_x = map.keys.map { |x, _| x }.max
  min_y = map.keys.map { |_, y| y }.min
  max_y = map.keys.map { |_, y| y }.max
  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      if x == 0 && y == 0
        print "\e[36m0\e[0m"
        next
      end

      if x == cur_x && y == cur_y
        print 'D'
        next
      end

      case map[[x, y]]
      when 0
        print "\e[31m#\e[0m"
      when 1
        print "\e[33m.\e[0m"
      when 2
        print "\e[36mS\e[0m"
      else
        print '?'
      end
    end
    print "\n"
  end
end

def draw_map_with_filled(map, filled)
  min_x = map.keys.map { |x, _| x }.min
  max_x = map.keys.map { |x, _| x }.max
  min_y = map.keys.map { |_, y| y }.min
  max_y = map.keys.map { |_, y| y }.max
  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      if filled.include?([x, y])
        print "\e[36mF\e[0m"
        next
      end

      case map[[x, y]]
      when 0
        print "\e[31m#\e[0m"
      when 1
        print "\e[33m.\e[0m"
      when 2
        print "\e[36mS\e[0m"
      else
        print '?'
      end
    end
    print "\n"
  end
end

def reconstruct_path(came_from, current)
  total_path = Set.new([current])
  while came_from.keys.include?(current)
    current = came_from[current]
    total_path << current
  end
  total_path
end

def a_star(start, goal, map)
  open_set = Set.new([start])

  came_from = {}

  g_score = Hash.new(Float::INFINITY)
  g_score[start] = 0

  f_score = Hash.new(Float::INFINITY)
  f_score[start] = manhattan(start)

  while !open_set.empty?
    current = open_set.min_by { |node| f_score[node] }
    if current == goal
      return reconstruct_path(came_from, current)
    end

    open_set.delete(current)
    neighbors(current, map).each do |neighbor|
      tentative_g_score = g_score[current] + 1
      if tentative_g_score < g_score[neighbor]
        came_from[neighbor] = current
        g_score[neighbor] = tentative_g_score
        f_score[neighbor] = g_score[neighbor] + manhattan(neighbor)
        unless open_set.include?(neighbor)
          open_set.add(neighbor)
        end
      end
    end
  end

  raise "goal not reached"
end

def neighbors(current, map)
  x, y = current
  [[x, y - 1], [x, y + 1], [x - 1, y], [x + 1, y]].reject do |nx, ny|
    map[[nx, ny]] == 0
  end
end

def manhattan(node)
  x, y = node
  x.abs + y.abs
end

# Part 1

c = Intcode.new(program.dup)

x, y = 0, 0
map = { [x, y] => 1 }
scores = Hash.new(0)
scores[[x, y]] = 1

start = Time.now

loop do
  direction = choose_direction(x, y, map, scores)
  c.inputs << direction

  loop do
    c.step
    break if c.state == :output_available || c.state == :halted
  end
  break if c.state == :halted

  output = c.outputs.shift

  update_scores(scores, x, y, direction, output)
  update_map(map, x, y, direction, output)
  next if output == 0
  x, y = update_coords(x, y, direction)
  break if Time.now > start + 5
end

# draw_map(map, x, y)

x, y = map.keys.select { |p| map[p] == 2 }[0]
path = a_star([x, y], [0, 0], map)
puts path.size - 1

# Part 2

n = 0

filled = Set.new([[x, y]])
last_filled = filled.dup
rooms = Set.new(map.select { |_, v| v != 0 }.keys)

until filled == rooms
  new_last_filled = []
  last_filled.each do |fx, fy|
    neighbors([fx, fy], map).each do |nx, ny|
      next if filled.include?([nx, ny])
      filled << [nx, ny]
      new_last_filled << [nx, ny]
    end
  end

  last_filled = new_last_filled
  n += 1
end

# draw_map_with_filled(map, filled)

puts n
