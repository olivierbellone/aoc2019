#!/usr/bin/env ruby
# frozen_string_literal: true

input = File.read('day12.txt').lines.map(&:strip)

Position = Struct.new(:x, :y, :z)

Velocity = Struct.new(:x, :y, :z)

class Moon
  attr_accessor :pos, :vel

  def initialize(pos, vel)
    @pos, @vel = pos, vel
  end

  def apply_gravity(other)
    @vel.x += other.pos.x <=> @pos.x
    other.vel.x += @pos.x <=> other.pos.x

    @vel.y += other.pos.y <=> @pos.y
    other.vel.y += @pos.y <=> other.pos.y

    @vel.z += other.pos.z <=> @pos.z
    other.vel.z += @pos.z <=> other.pos.z
  end

  def apply_velocity
    @pos.x += @vel.x
    @pos.y += @vel.y
    @pos.z += @vel.z
  end

  def potential_energy
    @pos.x.abs + @pos.y.abs + @pos.z.abs
  end

  def kinetic_energy
    @vel.x.abs + @vel.y.abs + @vel.z.abs
  end

  def total_energy
    potential_energy * kinetic_energy
  end

  def ==(other)
    other.class == self.class && other.pos == @pos && other.vel == @vel
  end
end

class System
  attr_accessor :moons

  def initialize(moons)
    @moons = moons
  end

  def step
    apply_gravity
    apply_velocity
  end

  def apply_gravity
    moons.combination(2).each do |a, b|
      a.apply_gravity(b)
    end
  end

  def apply_velocity
    moons.each { |moon| moon.apply_velocity }
  end

  def potential_energy
    moons.map(&:potential_energy).sum
  end

  def kinetic_energy
    moons.map(&:kinetic_energy).sum
  end

  def total_energy
    moons.map(&:total_energy).sum
  end

  def ==(other)
    other.class == self.class && other.moons == @moons
  end
end

# Part 1

positions = input.map do |line|
  line.match(/^<x=([-]?\d+), y=([-]?\d+), z=([-+]?\d+)>$/) { |m| Position.new(*m.captures.map(&:to_i)) }
end

moons = positions.map do |pos|
  Moon.new(pos, Velocity.new(0, 0, 0))
end

system = System.new(moons)

1000.times { system.step }

puts system.total_energy

# Part 2

positions = input.map do |line|
  line.match(/^<x=([-]?\d+), y=([-]?\d+), z=([-+]?\d+)>$/) { |m| Position.new(*m.captures.map(&:to_i)) }
end

orig_moons = positions.map do |pos|
  Moon.new(pos.dup, Velocity.new(0, 0, 0))
end
moons = positions.map do |pos|
  Moon.new(pos.dup, Velocity.new(0, 0, 0))
end

orig_system = System.new(orig_moons)
system = System.new(moons)

period_x, period_y, period_z = -1, -1, -1

i = 0
loop do
  system.step
  i += 1

  if system.moons.zip(orig_system.moons).all? { |a, b| a.pos.x == b.pos.x && a.vel.x == b.vel.x }
    period_x = i
  end

  if system.moons.zip(orig_system.moons).all? { |a, b| a.pos.y == b.pos.y && a.vel.y == b.vel.y }
    period_y = i
  end

  if system.moons.zip(orig_system.moons).all? { |a, b| a.pos.z == b.pos.z && a.vel.z == b.vel.z }
    period_z = i
  end

  break if [period_x, period_y, period_z].all?(&:positive?)
end

puts [period_x, period_y, period_z].reduce(&:lcm)
