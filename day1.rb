#!/usr/bin/env ruby
# frozen_string_literal: true

input = File.read('day1.txt').split.map(&:to_i)

# Part 1

puts input.map { |m| (m / 3).floor - 2 }.sum

# Part 2

def fuel(mass)
  f = (mass / 3).floor - 2
  return 0 if f <= 0

  f + fuel(f)
end

puts input.map { |m| fuel(m) }.sum
