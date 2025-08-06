require 'rails_helper'

RSpec.describe AtmLocator, type: :lib do
  before do
    # Create test data
    @branch = create(:branch, city: 'Anytown', state: 'CA')
    @branch_atm = create(:atm_machine, branch: @branch, city: 'Anytown', state: 'CA', status: 'active', cash_available: 10000)
    @supermarket_atm = create(:atm_machine, branch: nil, location_type: 'supermarket', city: 'Anytown', state: 'CA', status: 'active', cash_available: 5000)
    @university_atm = create(:atm_machine, branch: nil, location_type: 'university', city: 'Anytown', state: 'CA', status: 'active', cash_available: 3000)
    @maintenance_atm = create(:atm_machine, branch: nil, location_type: 'mall', city: 'Anytown', state: 'CA', status: 'maintenance', cash_available: 8000)
    @no_cash_atm = create(:atm_machine, branch: nil, location_type: 'gas_station', city: 'Anytown', state: 'CA', status: 'active', cash_available: 0)
  end

  describe '.find_nearest_atm' do
    it 'returns a hash with ATM machine, user location, and selection reason' do
      result = AtmLocator.find_nearest_atm

      expect(result).to have_key(:atm_machine)
      expect(result).to have_key(:user_location)
      expect(result).to have_key(:selection_reason)

      expect(result[:atm_machine]).to be_an(AtmMachine)
      expect(result[:user_location]).to be_a(Hash)
      expect(result[:selection_reason]).to be_a(String)
    end

    it 'selects only operational ATMs (active status with cash)' do
      # Run multiple times to test randomization
      10.times do
        result = AtmLocator.find_nearest_atm
        selected_atm = result[:atm_machine]

        expect(selected_atm.status).to eq('active')
        expect(selected_atm.cash_available).to be > 0
        expect([@branch_atm, @supermarket_atm, @university_atm]).to include(selected_atm)
        expect([@maintenance_atm, @no_cash_atm]).not_to include(selected_atm)
      end
    end

    it 'prioritizes ATMs in the same city as user location' do
      # Since all our test ATMs are in the same city, they should all be available
      selected_atms = []
      20.times do
        result = AtmLocator.find_nearest_atm
        selected_atms << result[:atm_machine]
      end

      # Should only select from operational ATMs in the same city
      expect(selected_atms.uniq.sort).to eq([@branch_atm, @supermarket_atm, @university_atm].sort)
    end

    it 'falls back to any operational ATM when no nearby ATMs available' do
      # Create ATMs in different city
      other_city_atm = create(:atm_machine, city: 'Othercity', state: 'CA', status: 'active', cash_available: 15000)

      # Make all Anytown ATMs non-operational
      [@branch_atm, @supermarket_atm, @university_atm].each do |atm|
        atm.update!(status: 'maintenance')
      end

      result = AtmLocator.find_nearest_atm
      expect(result[:atm_machine]).to eq(other_city_atm)
    end

    it 'includes meaningful selection reasons' do
      result = AtmLocator.find_nearest_atm
      reason = result[:selection_reason]

      if result[:atm_machine].branch.present?
        expect(reason).to include('Nearest branch ATM')
      else
        expect(reason).to include('Convenient')
        expect(reason).to include('ATM')
      end
    end
  end

  describe '.find_atm_by_location_type' do
    it 'returns branch ATM when requested' do
      atm = AtmLocator.find_atm_by_location_type('branch')
      expect(atm.branch).to be_present
      expect(atm).to eq(@branch_atm)
    end

    it 'returns supermarket ATM when requested' do
      atm = AtmLocator.find_atm_by_location_type('supermarket')
      expect(atm.location_type).to eq('supermarket')
      expect(atm).to eq(@supermarket_atm)
    end

    it 'returns university ATM when requested' do
      atm = AtmLocator.find_atm_by_location_type('university')
      expect(atm.location_type).to eq('university')
      expect(atm).to eq(@university_atm)
    end

    it 'handles case-insensitive location preferences' do
      atm = AtmLocator.find_atm_by_location_type('SUPERMARKET')
      expect(atm.location_type).to eq('supermarket')

      atm = AtmLocator.find_atm_by_location_type('University')
      expect(atm.location_type).to eq('university')
    end

    it 'falls back to random selection for unknown preferences' do
      atm = AtmLocator.find_atm_by_location_type('unknown_location')
      expect([@branch_atm, @supermarket_atm, @university_atm]).to include(atm)
    end

    it 'only selects operational ATMs' do
      # Make supermarket ATM non-operational
      @supermarket_atm.update!(status: 'out_of_service')

      atm = AtmLocator.find_atm_by_location_type('supermarket')
      expect(atm).to be_nil
    end
  end

  describe 'USER_LOCATIONS constant' do
    it 'contains realistic location data' do
      locations = AtmLocator::USER_LOCATIONS

      expect(locations).to be_an(Array)
      expect(locations).not_to be_empty

      locations.each do |location|
        expect(location).to have_key(:name)
        expect(location).to have_key(:city)
        expect(location).to have_key(:state)
        expect(location).to have_key(:zipcode)

        expect(location[:name]).to be_a(String)
        expect(location[:city]).to be_a(String)
        expect(location[:state]).to be_a(String)
        expect(location[:zipcode]).to be_a(String)
      end
    end
  end
end
