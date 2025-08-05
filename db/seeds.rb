# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data for clean seeding
Card.destroy_all
Account.destroy_all
Customer.destroy_all

puts "Creating test customer..."

# Create a test customer
customer = Customer.create!(
  name: "John Doe",
  address: "123 Main Street",
  city: "Anytown",
  state: "CA",
  zipcode: "12345"
)

puts "Created customer: #{customer.name}"

# Create a test account
account = Account.create!(
  customer: customer,
  account_number: "1234567890123456",
  account_type: "checking",
  balance: 2500.00
)

puts "Created account: #{account.account_number} with balance: $#{account.balance}"

# Create multiple test cards for the same account with different cardholders
# All cards use the same network (Visa) as they're from the same bank/account

card1 = Card.new(
  account: account,
  card_number: "4532015112830366",
  cardholder_name: "John Doe",
  card_type: "visa",
  expiration_date: 2.years.from_now,
  status: "active",
  pin: "1234",
  cvc: "123"
)
card1.save!

card2 = Card.new(
  account: account,
  card_number: "4532015112830374",
  cardholder_name: "Jane Doe",
  card_type: "visa",
  expiration_date: 18.months.from_now,
  status: "active",
  pin: "1234",
  cvc: "456"
)
card2.save!

card3 = Card.new(
  account: account,
  card_number: "4532015112830382",
  cardholder_name: "John Doe Jr",
  card_type: "visa",
  expiration_date: 3.years.from_now,
  status: "active",
  pin: "1234",
  cvc: "789"
)
card3.save!

puts "Created ATM cards for the same account:"
puts "1. #{card1.card_number} - #{card1.cardholder_name} (Primary account holder)"
puts "2. #{card2.card_number} - #{card2.cardholder_name} (Spouse)"
puts "3. #{card3.card_number} - #{card3.cardholder_name} (Authorized user)"
puts ""
puts "All cards are Visa debit cards from the same bank for the same checking account"
puts ""
puts "Test login credentials (any card works):"
puts "Card Number: 4532015112830366"
puts "PIN: 1234"
