#!/usr/bin/env ruby
# frozen_string_literal: true

input = File.read('day10.txt').strip

asteroids = {}
input.lines.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    asteroids[[x, y]] = -1 if char == '#'
  end
end

height = input.lines.size
width = input.lines[0].length

def manhattan(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 - y2).abs
end

def steps(x1, y1, x2, y2)
  xstep = x2 - x1
  ystep = y2 - y1
  loop do
    gcd = xstep.gcd(ystep)
    break if gcd == 1
    xstep /= gcd
    ystep /= gcd
  end
  [xstep, ystep]
end


asteroids.keys.each do |x1, y1|
  asteroids[[x1, y1]] = 0

  other = (asteroids.keys.dup - [[x1, y1]]).sort_by { |x2, y2| manhattan(x1, y1, x2, y2) }

  until other.empty?
    x2, y2 = other.shift

    asteroids[[x1, y1]] += 1

    xstep, ystep = steps(x1, y1, x2, y2)
    x3, y3 = x1, y1
    loop do

      x3 += xstep
      y3 += ystep

      break if x3 < 0 || x3 >= width || y3 < 0 || y3 >= height

      if other.include?([x3, y3])
        other.delete([x3, y3])
      end
    end
  end
end

best = asteroids.sort_by {|_, v| -v}.first
puts best[1]

x1, y1 = best[0]

other = (asteroids.keys.dup - [[x1, y1]])

destroyed = []

until other.empty?
  angles = {}
  other.each do |x2, y2|
    angle = -Complex(y2 - y1, x2 - x1).phase
    angles[angle] = [] unless angles.key?(angle)
    angles[angle] << [x2, y2]
  end

  angles.transform_values! { |coords| coords.sort_by { |x, y| manhattan(x1, y1, x, y) } }

  angles.keys.sort.each do |angle|
    target = angles[angle].shift
    other.delete(target)
    destroyed << target
  end
end

result = destroyed[199]
puts result[0] * 100 + result[1]
