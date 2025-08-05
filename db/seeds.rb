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

puts "Created account: #{account.formatted_account_number} with balance: $#{account.balance}"

# Create a test card with PIN 1234
card = Card.new(
  account: account,
  card_number: "4532015112830366",
  card_type: "visa",
  expiration_date: 2.years.from_now,
  status: "active",
  pin: "1234",
  cvc: "123"
)

card.save!

puts "Created card: #{card.formatted_display} with PIN: 1234"
puts "Test login credentials:"
puts "Card Number: 4532015112830366"
puts "PIN: 1234"
