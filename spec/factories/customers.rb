FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zipcode { Faker::Address.zip_code }

    # Factory for invalid customer with name too long
    trait :invalid_name do
      name { "a" * 251 }
    end

    # Factory for invalid customer with address too long
    trait :invalid_address do
      address { "a" * 251 }
    end

    # Factory for invalid customer with invalid state
    trait :invalid_state do
      state { "ABC" }
    end

    # Factory for invalid customer with invalid zipcode
    trait :invalid_zipcode do
      zipcode { "invalid" }
    end

    # Factory for customer with missing required fields
    trait :missing_name do
      name { nil }
    end

    trait :missing_address do
      address { nil }
    end

    trait :missing_city do
      city { nil }
    end

    trait :missing_state do
      state { nil }
    end

    trait :missing_zipcode do
      zipcode { nil }
    end
  end
end
