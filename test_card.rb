puts "=== Testing Card Creation ==="

# Create dependencies
customer = Customer.create!(
  name: 'Test Customer',
  address: '123 Main St',
  city: 'Test City',
  state: 'CA',
  zipcode: '12345'
)

account = Account.create!(
  customer: customer,
  account_number: "#{Time.now.to_i}",
  account_type: 'checking'
)

# Create card
card = Card.new(
  account: account,
  card_number: '4532015112830366',
  pin: '1234',
  cvc: '123',
  card_type: 'visa',
  expiration_date: 2.years.from_now.to_date
)

puts "PIN set: #{card.pin}"
puts "CVC set: #{card.cvc}"
puts "Valid?: #{card.valid?}"
puts "Errors: #{card.errors.full_messages}"

if card.save
  puts "Card saved successfully!"
  puts "PIN digest: #{card.pin_digest}"
  puts "CVC digest: #{card.cvc_digest}"
else
  puts "Failed to save card"
  puts "Errors: #{card.errors.full_messages}"
end
