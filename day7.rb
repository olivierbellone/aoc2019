#!/usr/bin/env ruby
# frozen_string_literal: true

program = File.read('day7.txt').split(',').map(&:to_i)

class Intcode
  attr_accessor :program, :inputs, :output, :ip, :state

  def initialize(program, inputs, output = nil, ip = 0)
    @program = program
    @inputs = inputs
    @output = output
    @ip = ip
    @state = :initialized
  end

  def run!(pause_on_output = false)
    @state = :running
    opcode, modes = process_instruction

    case opcode
    when 1
      param1 = process_parameter(@program, @program[@ip += 1], modes[0])
      param2 = process_parameter(@program, @program[@ip += 1], modes[1])
      write_addr = @program[@ip += 1]
      @program[write_addr] = param1 + param2
    when 2
      param1 = process_parameter(@program, @program[@ip += 1], modes[0])
      param2 = process_parameter(@program, @program[@ip += 1], modes[1])
      write_addr = @program[@ip += 1]
      @program[write_addr] = param1 * param2
    when 3
      raise 'No more inputs' if @inputs.empty?

      write_addr = @program[@ip += 1]
      @program[write_addr] = @inputs.shift
    when 4
      param1 = process_parameter(@program, @program[@ip += 1], modes[0])
      @output = param1
      @state = :output_available
    when 5
      param1 = process_parameter(@program, @program[@ip += 1], modes[0])
      param2 = process_parameter(@program, @program[@ip += 1], modes[1])
      @ip = param2 - 1 unless param1.zero?
    when 6
      param1 = process_parameter(@program, @program[@ip += 1], modes[0])
      param2 = process_parameter(@program, @program[@ip += 1], modes[1])
      @ip = param2 - 1 if param1.zero?
    when 7
      param1 = process_parameter(@program, @program[@ip += 1], modes[0])
      param2 = process_parameter(@program, @program[@ip += 1], modes[1])
      write_addr = @program[@ip += 1]
      @program[write_addr] = param1 < param2 ? 1 : 0
    when 8
      param1 = process_parameter(@program, @program[@ip += 1], modes[0])
      param2 = process_parameter(@program, @program[@ip += 1], modes[1])
      write_addr = @program[@ip += 1]
      @program[write_addr] = param1 == param2 ? 1 : 0
    when 99
      @state = :halted
      return
    else
      raise "Unknown opcode #{opcode} at address #{@ip}"
    end

    @ip += 1

    return if pause_on_output && @state == :output_available

    run!(pause_on_output)
  end

  def process_instruction
    s = format('%<value>05d', value: @program[@ip])
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
end

# Part 1

max_signal = (0..4).to_a.permutation.map do |seq|
  input = 0
  seq.each do |phase|
    intcode = Intcode.new(program.dup, [phase, input])
    intcode.run!
    input = intcode.output
  end
  input
end.max

puts max_signal

# Part 2

max_signal = (5..9).to_a.permutation.map do |seq|
  amplifiers = seq.map {|phase| Intcode.new(program.dup, [phase])}

  input = 0
  while amplifiers[-1].state != :halted
    amplifiers.each do |amp|
      amp.inputs << input
      amp.run!(true)
      input = amp.output
    end
  end

  amplifiers[-1].output
end.max

puts max_signal
