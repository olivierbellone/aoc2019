#!/usr/bin/env ruby
# frozen_string_literal: true

WIDTH = 25
HEIGHT = 6

input = File.read('day8.txt').strip.chars.map(&:to_i)

layers = input.each_slice(WIDTH * HEIGHT).to_a

# Part 1

layer_min_zero = layers.min_by { |l| l.count(0) }
puts layer_min_zero.count(1) * layer_min_zero.count(2)

# Part 2

image = []
(0...WIDTH).each do |y|
  (0...WIDTH).each do |x|
    pixel = nil
    layers.each do |layer|
      pixel = layer[x + y * WIDTH]
      break if pixel != 2
    end
    image << pixel
  end
end

(0...HEIGHT).each do |y|
  (0...WIDTH).each do |x|
    print image[x + y * WIDTH] == 1 ? 'o' : ' '
  end
  print "\n"
end
