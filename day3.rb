#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

input = File.read('day3.txt').split
            .map { |line| line.split(',').map { |i| [i[0], i[1..-1].to_i] } }

def visited_cells(path)
  res = []
  x = 0
  y = 0

  path.each do |direction, distance|
    case direction
    when 'R'
      distance.times do
        res << [x += 1, y]
      end
    when 'L'
      distance.times do
        res << [x -= 1, y]
      end
    when 'U'
      distance.times do
        res << [x, y += 1]
      end
    when 'D'
      distance.times do
        res << [x, y -= 1]
      end
    else
      raise "Unknown direction: #{direction}"
    end
  end

  res
end

# Part 1

def manhattan(p)
  x, y = p
  x.abs + y.abs
end

cells1 = visited_cells(input[0])
cells2 = visited_cells(input[1])
intersections = (Set.new(cells1) & Set.new(cells2))
p intersections.map { |p| manhattan(p) }.min

# Part 2

def steps(p, cells1, cells2)
  cells1.find_index(p) + cells2.find_index(p) + 2
end

p intersections.map { |p| steps(p, cells1, cells2) }.min
