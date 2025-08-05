FactoryBot.define do
  factory :atm_machine do
    sequence(:machine_id) { |n| "ATM%05d" % n }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zipcode { Faker::Address.zip }
    country { 'USA' }
    status { 'active' }
    location_type { 'branch' }
    cash_available { 10000.00 }
    branch { association :branch }

    trait :standalone do
      branch { nil }
      location_type { 'standalone' }
    end

    trait :supermarket do
      branch { nil }
      location_type { 'supermarket' }
    end

    trait :gas_station do
      branch { nil }
      location_type { 'gas_station' }
    end

    trait :mall do
      branch { nil }
      location_type { 'mall' }
    end

    trait :out_of_service do
      status { 'out_of_service' }
    end

    trait :maintenance do
      status { 'maintenance' }
    end

    trait :out_of_cash do
      status { 'out_of_cash' }
      cash_available { 0 }
    end

    trait :offline do
      status { 'offline' }
    end

    trait :low_cash do
      cash_available { 500.00 }
    end

    trait :high_cash do
      cash_available { 50000.00 }
    end

    trait :manhattan_supermarket do
      machine_id { 'MNH12345' }
      address { '200 West 57th Street' }
      city { 'New York' }
      state { 'NY' }
      zipcode { '10019' }
      location_type { 'supermarket' }
      branch { nil }
    end

    trait :boston_mall do
      machine_id { 'BST67890' }
      address { '800 Boylston Street' }
      city { 'Boston' }
      state { 'MA' }
      zipcode { '02199' }
      location_type { 'mall' }
      branch { nil }
    end
  end
end
