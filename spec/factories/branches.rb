FactoryBot.define do
  factory :branch do
    sequence(:name) { |n| "Atlantic Bank Branch #{n}" }
    address { "#{Faker::Address.street_address}" }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zipcode { Faker::Address.zip }
    country { 'USA' }
    phone { Faker::PhoneNumber.phone_number.gsub(/\D/, '').first(10) }
    manager_name { Faker::Name.name }
    operating_hours { 'Mon-Fri 9:00 AM - 5:00 PM, Sat 9:00 AM - 1:00 PM' }
    sequence(:branch_code) { |n| "B%03d" % n }

    trait :with_atms do
      after(:create) do |branch|
        create_list(:atm_machine, 2, branch: branch)
      end
    end

    trait :manhattan do
      name { 'Atlantic Bank Manhattan Branch' }
      address { '100 Broadway' }
      city { 'New York' }
      state { 'NY' }
      zipcode { '10005' }
      branch_code { 'MNH1' }
    end

    trait :downtown do
      name { 'Atlantic Bank Downtown Branch' }
      address { '500 Main Street' }
      city { 'Boston' }
      state { 'MA' }
      zipcode { '02101' }
      branch_code { 'DTN1' }
    end
  end
end
