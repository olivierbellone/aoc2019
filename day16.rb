#!/usr/bin/env ruby
# frozen_string_literal: true

input = File.read('day16.txt').strip.chars.map(&:to_i)

# Part 1

output = input.dup

100.times do
  output.size.times do |i|
    pattern = ([0] * (i + 1) + [1] * (i + 1) + [0] * (i + 1) + [-1] * (i + 1)).rotate
    t = output.zip(pattern.cycle).map { |v1, v2| v1 * v2 }.sum
    output[i] = t.abs % 10
  end
end

puts output.join[0...8]

# Part 2

output = input.dup * 10_000
offset = input[0...7].join.to_i

100.times do
  partial_sum = output[offset..-1].sum
  (offset...(output.size)).each do |i|
    t = partial_sum
    partial_sum -= output[i]
    output[i] = t.abs % 10
  end
end

puts output.join[offset...(offset + 8)]
