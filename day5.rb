#!/usr/bin/env ruby
# frozen_string_literal: true

input = File.read('day5.txt').split(',').map(&:to_i)

def process(program, input, ip=0)
  opcode, modes = process_instruction(program[ip])
  case opcode
  when 1
    param1 = process_parameter(program, program[ip += 1], modes[0])
    param2 = process_parameter(program, program[ip += 1], modes[1])
    write_addr = program[ip += 1]
    program[write_addr] = param1 + param2
  when 2
    param1 = process_parameter(program, program[ip += 1], modes[0])
    param2 = process_parameter(program, program[ip += 1], modes[1])
    write_addr = program[ip += 1]
    program[write_addr] = param1 * param2
  when 3
    write_addr = program[ip += 1]
    program[write_addr] = input
  when 4
    param1 = process_parameter(program, program[ip += 1], modes[0])
    puts param1
  when 5
    param1 = process_parameter(program, program[ip += 1], modes[0])
    param2 = process_parameter(program, program[ip += 1], modes[1])
    ip = param2 - 1 unless param1.zero?
  when 6
    param1 = process_parameter(program, program[ip += 1], modes[0])
    param2 = process_parameter(program, program[ip += 1], modes[1])
    ip = param2 - 1 if param1.zero?
  when 7
    param1 = process_parameter(program, program[ip += 1], modes[0])
    param2 = process_parameter(program, program[ip += 1], modes[1])
    write_addr = program[ip += 1]
    program[write_addr] = param1 < param2 ? 1 : 0
  when 8
    param1 = process_parameter(program, program[ip += 1], modes[0])
    param2 = process_parameter(program, program[ip += 1], modes[1])
    write_addr = program[ip += 1]
    program[write_addr] = param1 == param2 ? 1 : 0
  when 99
    puts 'Halt!'
    return
  else
    raise "Unknown opcode #{opcode} at address #{ip}"
  end
  process(program, input, ip + 1)
end

def process_instruction(value)
  s = format('%<value>05d', value: value)
  opcode = s[-2..-1].to_i
  modes = s[0..2].chars.reverse.map(&:to_i)
  [opcode, modes]
end

def process_parameter(program, value, mode)
  case mode
  when 0
    program[value]
  when 1
    value
  else
    raise "Unknown parameter mode #{mode}"
  end
end

# Part 1

program = input.dup
process(program, 1)

# Part 2

program = input.dup
process(program, 5)
