#!/usr/bin/env ruby
require_relative 'config/environment'

# Test the factory with some sample data
puts "Testing Customer factory..."
puts "=" * 50

5.times do |i|
  customer = FactoryBot.build(:customer)
  puts "Customer #{i + 1}:"
  puts "  Name: #{customer.name}"
  puts "  Address: #{customer.address}"
  puts "  City: #{customer.city}"
  puts "  State: #{customer.state}"
  puts "  Zipcode: #{customer.zipcode}"
  puts "  Valid: #{customer.valid?}"
  puts "  Errors: #{customer.errors.full_messages}" unless customer.valid?
  puts ""
end

puts "Testing invalid traits..."
puts "=" * 50

# Test invalid name trait
customer = FactoryBot.build(:customer, :invalid_name)
puts "Invalid name customer:"
puts "  Valid: #{customer.valid?}"
puts "  Errors: #{customer.errors.full_messages}"
puts ""

# Test invalid zipcode trait
customer = FactoryBot.build(:customer, :invalid_zipcode)
puts "Invalid zipcode customer:"
puts "  Valid: #{customer.valid?}"
puts "  Errors: #{customer.errors.full_messages}"
puts ""

# Test missing required field
customer = FactoryBot.build(:customer, :missing_state)
puts "Missing state customer:"
puts "  Valid: #{customer.valid?}"
puts "  Errors: #{customer.errors.full_messages}"
