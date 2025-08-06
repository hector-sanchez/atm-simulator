# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data for clean seeding
puts "Clearing existing data..."
Transaction.destroy_all
AtmMachine.destroy_all
Branch.destroy_all
Card.destroy_all
Account.destroy_all
Customer.destroy_all

puts "Creating bank branches..."

# Create bank branches across different cities
branches = [
  {
    name: "Atlantic Bank Downtown",
    address: "100 Main Street",
    city: "Anytown",
    state: "CA",
    zipcode: "12345",
    phone: "5551234567",
    manager_name: "Sarah Johnson",
    branch_code: "DT01"
  },
  {
    name: "Atlantic Bank Westside",
    address: "500 Oak Avenue",
    city: "Anytown",
    state: "CA",
    zipcode: "12346",
    phone: "5552345678",
    manager_name: "Michael Chen",
    branch_code: "WS01"
  },
  {
    name: "Atlantic Bank University",
    address: "1500 College Drive",
    city: "University City",
    state: "CA",
    zipcode: "12350",
    phone: "5553456789",
    manager_name: "Dr. Emily Rodriguez",
    branch_code: "UC01"
  },
  {
    name: "Atlantic Bank Riverside",
    address: "750 River Road",
    city: "Riverside",
    state: "CA",
    zipcode: "12355",
    phone: "5554567890",
    manager_name: "David Park",
    branch_code: "RV01"
  },
  {
    name: "Atlantic Bank Metro Center",
    address: "2000 Metro Plaza",
    city: "Metro City",
    state: "CA",
    zipcode: "12360",
    phone: "5555678901",
    manager_name: "Lisa Thompson",
    branch_code: "MC01"
  }
]

created_branches = branches.map do |branch_data|
  Branch.create!(
    **branch_data,
    country: "USA",
    operating_hours: "Mon-Fri 9:00 AM - 6:00 PM, Sat 9:00 AM - 2:00 PM"
  )
end

puts "Created #{created_branches.length} branches"

puts "Creating ATM machines..."

# Create ATMs at branches
branch_atms = created_branches.map.with_index do |branch, index|
  AtmMachine.create!(
    machine_id: "ATM%05d" % (index + 1),
    address: branch.address,
    city: branch.city,
    state: branch.state,
    zipcode: branch.zipcode,
    country: "USA",
    status: "active",
    location_type: "branch",
    cash_available: rand(30000..60000),
    branch: branch
  )
end

# Create standalone ATMs at various locations
standalone_locations = [
  { location_type: "supermarket", address: "200 Shopping Center Dr", city: "Anytown", state: "CA", zipcode: "12347" },
  { location_type: "university", address: "1000 University Blvd", city: "University City", state: "CA", zipcode: "12351" },
  { location_type: "airport", address: "300 Airport Way", city: "Metro City", state: "CA", zipcode: "12361" },
  { location_type: "mall", address: "400 Mall Plaza", city: "Anytown", state: "CA", zipcode: "12348" },
  { location_type: "gas_station", address: "150 Highway 101", city: "Riverside", state: "CA", zipcode: "12356" },
  { location_type: "hospital", address: "600 Medical Center Dr", city: "Metro City", state: "CA", zipcode: "12362" },
  { location_type: "supermarket", address: "800 Grocery Lane", city: "University City", state: "CA", zipcode: "12352" },
  { location_type: "gas_station", address: "950 Interstate Blvd", city: "Anytown", state: "CA", zipcode: "12349" },
  { location_type: "mall", address: "1200 Shopping Way", city: "Riverside", state: "CA", zipcode: "12357" },
  { location_type: "airport", address: "250 Terminal Dr", city: "Anytown", state: "CA", zipcode: "12350" }
]

standalone_atms = standalone_locations.map.with_index do |location, index|
  AtmMachine.create!(
    machine_id: "ATM%05d" % (created_branches.length + index + 1),
    address: location[:address],
    city: location[:city],
    state: location[:state],
    zipcode: location[:zipcode],
    country: "USA",
    status: ["active", "active", "active", "maintenance", "out_of_service"].sample, # Most active, some maintenance
    location_type: location[:location_type],
    cash_available: rand(5000..35000),
    branch: nil
  )
end

all_atms = branch_atms + standalone_atms
puts "Created #{all_atms.length} ATM machines (#{branch_atms.length} at branches, #{standalone_atms.length} standalone)"

puts "Creating customers with accounts and cards..."

# Customer profiles with realistic data
customer_profiles = [
  {
    name: "John Anderson",
    address: "123 Main Street",
    city: "Anytown",
    state: "CA",
    zipcode: "12345",
    accounts: [
      { type: "checking", cards: ["John Anderson", "Jane Anderson"] },
      { type: "savings", cards: ["John Anderson"] }
    ]
  },
  {
    name: "Sarah Williams",
    address: "456 Oak Drive",
    city: "University City",
    state: "CA",
    zipcode: "12350",
    accounts: [
      { type: "checking", cards: ["Sarah Williams"] },
      { type: "savings", cards: ["Sarah Williams"] }
    ]
  },
  {
    name: "Michael Rodriguez",
    address: "789 Pine Street",
    city: "Riverside",
    state: "CA",
    zipcode: "12355",
    accounts: [
      { type: "checking", cards: ["Michael Rodriguez", "Maria Rodriguez"] },
      { type: "savings", cards: ["Michael Rodriguez"] },
      { type: "checking", cards: ["Maria Rodriguez"] }  # Separate checking for spouse
    ]
  },
  {
    name: "Emily Chen",
    address: "321 Elm Avenue",
    city: "Metro City",
    state: "CA",
    zipcode: "12360",
    accounts: [
      { type: "checking", cards: ["Emily Chen"] }
    ]
  },
  {
    name: "David Thompson",
    address: "654 Maple Lane",
    city: "Anytown",
    state: "CA",
    zipcode: "12346",
    accounts: [
      { type: "checking", cards: ["David Thompson", "Lisa Thompson"] },
      { type: "savings", cards: ["David Thompson", "Lisa Thompson"] }
    ]
  },
  {
    name: "Jessica Parker",
    address: "987 Cedar Court",
    city: "University City",
    state: "CA",
    zipcode: "12351",
    accounts: [
      { type: "checking", cards: ["Jessica Parker"] },
      { type: "savings", cards: ["Jessica Parker"] }
    ]
  }
]

all_cards = []

customer_profiles.each do |profile|
  customer = Customer.create!(
    name: profile[:name],
    address: profile[:address],
    city: profile[:city],
    state: profile[:state],
    zipcode: profile[:zipcode]
  )

  profile[:accounts].each_with_index do |account_info, account_index|
    account = Account.create!(
      customer: customer,
      account_number: "#{rand(1000..9999)}#{rand(1000..9999)}#{rand(1000..9999)}#{rand(1000..9999)}",
      account_type: account_info[:type],
      balance: 0.00  # Will be set by transactions
    )

    account_info[:cards].each_with_index do |cardholder_name, card_index|
      # Generate valid 16-digit card numbers for supported types
      card_number = case rand(3)  # Only 3 types supported: visa, mastercard, discover
                   when 0
                     # Visa: starts with 4, 16 digits
                     "4532" + rand(100000000000..999999999999).to_s.ljust(12, '0')[0..11]
                   when 1
                     # Mastercard: starts with 5, 16 digits
                     "5425" + rand(100000000000..999999999999).to_s.ljust(12, '0')[0..11]
                   else
                     # Discover: starts with 6011, 16 digits
                     "6011" + rand(100000000000..999999999999).to_s.ljust(12, '0')[0..11]
                   end

      card_type = case card_number[0]
                 when '4' then 'visa'
                 when '5' then 'mastercard'
                 when '6' then 'discover'
                 end

      card = Card.create!(
        account: account,
        card_number: card_number,
        cardholder_name: cardholder_name,
        card_type: card_type,
        expiration_date: rand(1..4).years.from_now,
        status: "active",
        pin: "1234",  # Simple PIN for demo
        cvc: rand(100..999).to_s
      )

      all_cards << card
    end
  end
end

puts "Created #{Customer.count} customers with #{Account.count} accounts and #{Card.count} cards"

puts "Creating realistic transaction history..."

# Create transactions for each card, starting with credits to avoid negative balances
all_cards.each do |card|
  account = card.account
  atm = all_atms.select { |a| a.operational? }.sample

  # First transaction should be a credit (deposit) to establish positive balance
  initial_deposit = rand(500..5000)
  Transaction.create!(
    card: card,
    atm_machine: atm,
    amount: initial_deposit,  # Positive amount
    transaction_type: "credit",
    source: "atm"
  )

  # Create 5-15 additional transactions per card
  num_transactions = rand(5..15)

  num_transactions.times do
    atm = all_atms.select { |a| a.operational? }.sample

    # 70% withdrawals, 30% deposits
    if rand < 0.7
      # Withdrawal (debit) - make sure we don't overdraw
      current_balance = account.reload.balance
      max_withdrawal = [current_balance - 10, 20].max  # Leave at least $10, min $20 withdrawal
      next if max_withdrawal < 20

      withdrawal_amount = rand(20..[max_withdrawal, 500].min)
      Transaction.create!(
        card: card,
        atm_machine: atm,
        amount: withdrawal_amount,  # Positive amount, type determines debit
        transaction_type: "debit",
        source: "atm"
      )
    else
      # Deposit (credit)
      deposit_amount = rand(50..1000)
      Transaction.create!(
        card: card,
        atm_machine: atm,
        amount: deposit_amount,  # Positive amount
        transaction_type: "credit",
        source: "atm"
      )
    end

    # Small chance of teller transaction
    if rand < 0.1
      transfer_amount = rand(25..200)
      current_balance = account.reload.balance
      next if current_balance < transfer_amount + 10

      Transaction.create!(
        card: card,
        atm_machine: atm,
        amount: transfer_amount,  # Positive amount, type determines debit
        transaction_type: "debit",
        source: "teller"
      )
    end
  end
end

puts "Created #{Transaction.count} transactions"

# Display summary
puts "\n" + "="*60
puts "SEED DATA SUMMARY"
puts "="*60

puts "\nBRANCHES:"
created_branches.each do |branch|
  puts "• #{branch.name} - #{branch.city}, #{branch.state}"
end

puts "\nATM MACHINES:"
all_atms.group_by(&:status).each do |status, atms|
  puts "• #{status.humanize}: #{atms.count} ATMs"
end

puts "\nCUSTOMERS & ACCOUNTS:"
Customer.includes(:accounts).each do |customer|
  puts "• #{customer.name} - #{customer.accounts.count} account(s)"
  customer.accounts.each do |account|
    puts "  - #{account.account_type.humanize}: #{account.cards.count} card(s), Balance: $#{'%.2f' % account.balance}"
  end
end

puts "\nTRANSACTIONS:"
Transaction.group(:source).count.each do |source, count|
  puts "• #{source.humanize}: #{count} transactions"
end

successful_transactions = Transaction.where(status: 'approved').count
failed_transactions = Transaction.where(status: 'denied').count
puts "• Approved: #{successful_transactions}, Denied: #{failed_transactions}"

puts "\nTEST CREDENTIALS:"
sample_card = all_cards.first
puts "Card Number: #{sample_card.card_number}"
puts "PIN: #{sample_card.pin}"
puts "Cardholder: #{sample_card.cardholder_name}"
puts "Account Balance: $#{'%.2f' % sample_card.account.balance}"

puts "\n" + "="*60
puts "Seeding completed successfully!"
puts "="*60
