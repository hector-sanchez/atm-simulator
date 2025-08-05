FactoryBot.define do
  factory :account do
    customer
    account_number { Faker::Bank.account_number(digits: 10) }
    balance { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    account_type { %w[checking savings].sample }

    trait :checking do
      account_type { 'checking' }
      balance { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    end

    trait :savings do
      account_type { 'savings' }
      balance { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    end

    trait :zero_balance do
      balance { 0.00 }
    end

    trait :high_balance do
      balance { Faker::Number.decimal(l_digits: 5, r_digits: 2) }
    end
  end
end
