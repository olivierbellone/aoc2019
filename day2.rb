#!/usr/bin/env ruby
# frozen_string_literal: true

def fuel(mass)
  f = (mass / 3).floor - 2
  return 0 if f <= 0

  f + fuel(f)
end

puts File.read('day1.txt').split.map { |m| fuel(m.to_i) }.sum
