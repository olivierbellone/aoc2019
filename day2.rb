#!/usr/bin/env ruby
# frozen_string_literal: true

input = File.read('day2.txt').split(',').map(&:to_i)

def process(program, pos=0)
  opcode = program[pos]
  pos1, pos2, pos3 = program[pos + 1..pos + 3]
  case opcode
  when 1
    program[pos3] = program[pos1] + program[pos2]
  when 2
    program[pos3] = program[pos1] * program[pos2]
  when 99
    return program[0]
  else
    puts "Unknown opcode #{opcode} at position #{pos}"
  end
  process(program, pos + 4)
end

# Part 1

program = input.dup

program[1] = 12
program[2] = 2

p process(program)

# Part 2

(0..99).each do |noun|
  (0..99).each do |verb|
    program = input.dup
    program[1] = noun
    program[2] = verb
    result = process(program)
    if result == 19_690_720
      p 100 * noun + verb
      exit(0)
    end
  end
end
