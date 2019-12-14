#!/usr/bin/env ruby
# frozen_string_literal: true

input = File.read('day14.txt').lines.map(&:strip)

class Nanofactory
  attr_accessor :reactions, :unused

  def initialize(reactions)
    @reactions = reactions
    @unused = {}
  end

  def self.from_lines(lines)
    new(lines.map do |line|
      inp, outp = line.split(' => ')
      inp = inp.split(', ').map { |i| i.split(' ') }.map { |qty, chemical| [chemical, qty.to_i] }
      outp = outp.split(' ')
      [outp[1], [outp[0].to_i, inp]]
    end.to_h)
  end

  def get_ore_qty(req_chemical, req_qty)
    if @unused.key?(req_chemical)
      remaining_qty = @unused[req_chemical]
      if remaining_qty >= req_qty
        @unused[req_chemical] -= req_qty
        return 0
      else
        @unused.delete(req_chemical)
        return get_ore_qty(req_chemical, req_qty - remaining_qty)
      end
    end

    return req_qty if req_chemical == 'ORE'

    output_qty, input_chemicals = @reactions[req_chemical]
    factor = (req_qty * 1.0 / output_qty).ceil
    remaining_qty = (output_qty * factor) - req_qty
    if remaining_qty > 0
      @unused[req_chemical] = 0 unless @unused.key?(req_chemical)
      @unused[req_chemical] += remaining_qty
    end

    input_chemicals.map do |input_chemical, input_quantity|
      get_ore_qty(input_chemical, input_quantity * factor)
    end.sum
  end
end

# Part 1

factory = Nanofactory.from_lines(input)

ore_per_fuel = factory.get_ore_qty('FUEL', 1)
puts ore_per_fuel

# Part 2

factory = Nanofactory.from_lines(input)
factory.unused = { 'ORE' => 1_000_000_000_000 }

inc = 1_000
n = 0

while factory.unused.key?('ORE')
  unused = factory.unused.dup
  factory.get_ore_qty('FUEL', inc)
  if factory.unused.key?('ORE')
    n += inc
  else
    break if inc == 1

    inc /= 10
    factory.unused = unused
  end
end

p n
