#!/usr/bin/env ruby
# frozen_string_literal: true

input = File.read('day6.txt').split.map { |l| l.split(')') }

h = {}
input.each do |a, b|
  h[a] = [] unless h.key?(a)
  h[a] << b
end

def parents(h, p, res = [])
  parent = h.find { |_k, v| v.include?(p) }&.first
  return res if parent.nil?

  parents(h, parent, res + [parent])
end

# Part 1

all = h.values.flatten.uniq
p all.reduce(0) { |acc, k| acc + parents(h, k).size }

# Part 2

parents_you = parents(h, 'YOU')
parents_san = parents(h, 'SAN')

closest_common = (parents_you & parents_san).first
p parents_you.index(closest_common) + parents_san.index(closest_common)
