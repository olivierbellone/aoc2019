#!/usr/bin/env ruby
# frozen_string_literal: true

puts File.read('day1.txt').split.map { |m| (m.to_i / 3).floor - 2 }.sum
