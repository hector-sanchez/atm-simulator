FactoryBot.define do
  factory :transaction do
    card
    atm_machine { build(:atm_machine) }
    amount { '100.00' }
    transaction_type { 'debit' }
    source { 'atm' }
    status { 'pending' }
    description { 'ATM withdrawal' }

    trait :credit do
      transaction_type { 'credit' }
      description { 'ATM deposit' }
    end

    trait :debit do
      transaction_type { 'debit' }
      description { 'ATM withdrawal' }
    end

    trait :approved do
      status { 'approved' }
      processed_at { Time.current }
    end

    trait :denied do
      status { 'denied' }
      processed_at { Time.current }
    end

    trait :pending do
      status { 'pending' }
      processed_at { nil }
    end

    trait :cancelled do
      status { 'cancelled' }
      processed_at { Time.current }
    end

    trait :from_atm do
      source { 'atm' }
      atm_machine { build(:atm_machine) }
    end

    trait :from_teller do
      source { 'teller' }
      atm_machine { nil }
    end

    trait :large_amount do
      amount { '1000.00' }
    end

    trait :small_amount do
      amount { '20.00' }
    end

    # Specific transaction scenarios
    trait :insufficient_funds do
      amount { '10000.00' } # Assume this exceeds typical account balance
      status { 'denied' }
      description { 'Withdrawal denied - insufficient funds' }
    end

    trait :with_low_balance_account do
      association :card, factory: [:card, :with_low_balance_account]
      amount { '100.00' }
    end

    trait :with_high_balance_account do
      association :card, factory: [:card, :with_high_balance_account]
      amount { '100.00' }
    end
  end
end
