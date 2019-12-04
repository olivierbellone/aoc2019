#!/usr/bin/env ruby
# frozen_string_literal: true

input = '165432-707912'.split('-')

# Part 1

def possible_passwords(min, max)
  res = []

  (min..max).each do |n|
    digits = n.to_s.split('').map(&:to_i)

    next unless digits == digits.sort

    two_adjacent_digits = false
    (1..5).each do |i|
      if digits[i - 1] == digits[i]
        two_adjacent_digits = true
        break
      end
    end
    next unless two_adjacent_digits

    res << n
  end

  res
end

passwords = possible_passwords(*input)
p passwords.size

# Part 2

passwords.reject! do |password|
  digits = password.to_s.split('').map(&:to_i)
  !digits.uniq.any? { |d| digits.count(d) == 2 }
end

p passwords.size
