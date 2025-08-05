# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data for clean seeding
AtmMachine.destroy_all
Branch.destroy_all
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

# Create bank branches
puts "Creating bank branches..."

branch1 = Branch.create!(
  name: "Atlantic Bank Downtown",
  address: "100 Main Street",
  city: "Anytown",
  state: "CA",
  zipcode: "12345",
  country: "USA",
  phone: "5551234567",
  manager_name: "Sarah Johnson",
  operating_hours: "Mon-Fri 9:00 AM - 5:00 PM, Sat 9:00 AM - 1:00 PM",
  branch_code: "DT01"
)

branch2 = Branch.create!(
  name: "Atlantic Bank Westside",
  address: "500 Oak Avenue",
  city: "Anytown",
  state: "CA",
  zipcode: "12346",
  country: "USA",
  phone: "5552345678",
  manager_name: "Michael Chen",
  operating_hours: "Mon-Fri 9:00 AM - 6:00 PM, Sat 9:00 AM - 2:00 PM",
  branch_code: "WS01"
)

puts "Created branches:"
puts "1. #{branch1.name} - #{branch1.full_address}"
puts "2. #{branch2.name} - #{branch2.full_address}"
puts ""

# Create ATM machines
puts "Creating ATM machines..."

# ATMs at branches
atm1 = AtmMachine.create!(
  machine_id: "ATM00001",
  address: "100 Main Street",
  city: "Anytown",
  state: "CA",
  zipcode: "12345",
  country: "USA",
  status: "active",
  location_type: "branch",
  cash_available: 50000.00,
  branch: branch1
)

atm2 = AtmMachine.create!(
  machine_id: "ATM00002",
  address: "500 Oak Avenue",
  city: "Anytown",
  state: "CA",
  zipcode: "12346",
  country: "USA",
  status: "active",
  location_type: "branch",
  cash_available: 45000.00,
  branch: branch2
)

# Standalone ATMs at various locations
atm3 = AtmMachine.create!(
  machine_id: "ATM00003",
  address: "200 Shopping Center Dr",
  city: "Anytown",
  state: "CA",
  zipcode: "12347",
  country: "USA",
  status: "active",
  location_type: "supermarket",
  cash_available: 25000.00,
  branch: nil
)

atm4 = AtmMachine.create!(
  machine_id: "ATM00004",
  address: "1000 University Blvd",
  city: "Anytown",
  state: "CA",
  zipcode: "12348",
  country: "USA",
  status: "active",
  location_type: "university",
  cash_available: 15000.00,
  branch: nil
)

atm5 = AtmMachine.create!(
  machine_id: "ATM00005",
  address: "300 Airport Way",
  city: "Anytown",
  state: "CA",
  zipcode: "12349",
  country: "USA",
  status: "maintenance",
  location_type: "airport",
  cash_available: 30000.00,
  branch: nil
)

puts "Created ATM machines:"
puts "1. #{atm1.machine_id} - #{atm1.location_name} (#{atm1.status_display}) - #{atm1.formatted_cash_available}"
puts "2. #{atm2.machine_id} - #{atm2.location_name} (#{atm2.status_display}) - #{atm2.formatted_cash_available}"
puts "3. #{atm3.machine_id} - #{atm3.location_name} (#{atm3.status_display}) - #{atm3.formatted_cash_available}"
puts "4. #{atm4.machine_id} - #{atm4.location_name} (#{atm4.status_display}) - #{atm4.formatted_cash_available}"
puts "5. #{atm5.machine_id} - #{atm5.location_name} (#{atm5.status_display}) - #{atm5.formatted_cash_available}"
puts ""

puts "All cards are Visa debit cards from the same bank for the same checking account"
puts ""
puts "Test login credentials (any card works):"
puts "Card Number: 4532015112830366"
puts "PIN: 1234"
