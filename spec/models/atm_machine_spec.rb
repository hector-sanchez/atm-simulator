require 'rails_helper'

RSpec.describe AtmMachine, type: :model do
  describe 'validations' do
    let(:atm) { build(:atm_machine) }

    it 'validates presence and uniqueness of machine_id' do
      atm.machine_id = nil
      expect(atm).not_to be_valid
      expect(atm.errors[:machine_id]).to include("can't be blank")

      atm.machine_id = 'ATM12345'
      atm.save!

      duplicate_atm = build(:atm_machine, machine_id: 'ATM12345')
      expect(duplicate_atm).not_to be_valid
      expect(duplicate_atm.errors[:machine_id]).to include('has already been taken')
    end

    it 'validates machine_id format and length' do
      atm.machine_id = 'atm12345'
      expect(atm).not_to be_valid
      expect(atm.errors[:machine_id]).to include('must be 8 alphanumeric characters')

      atm.machine_id = 'ATM1234'
      expect(atm).not_to be_valid
      expect(atm.errors[:machine_id]).to include('is the wrong length (should be 8 characters)')
    end

    it 'validates presence of required fields' do
      %w[address city state zipcode country status location_type].each do |field|
        atm.send("#{field}=", nil)
        expect(atm).not_to be_valid
        expect(atm.errors[field.to_sym]).to include("can't be blank")
      end
    end

    it 'validates state length' do
      atm.state = 'ABC'
      expect(atm).not_to be_valid
      expect(atm.errors[:state]).to include('is the wrong length (should be 2 characters)')
    end

    it 'validates zipcode format' do
      atm.zipcode = '12345'
      expect(atm).to be_valid

      atm.zipcode = '12345-6789'
      expect(atm).to be_valid

      atm.zipcode = 'invalid'
      expect(atm).not_to be_valid
      expect(atm.errors[:zipcode]).to include('must be a valid US postal code')
    end

    it 'validates cash_available is numeric and non-negative' do
      atm.cash_available = -100
      expect(atm).not_to be_valid
      expect(atm.errors[:cash_available]).to include('must be greater than or equal to 0')

      atm.cash_available = 'not_a_number'
      expect(atm).not_to be_valid
      expect(atm.errors[:cash_available]).to include('is not a number')
    end
  end

  describe 'associations' do
    it 'belongs to branch optionally' do
      atm_with_branch = create(:atm_machine, branch: create(:branch))
      expect(atm_with_branch.branch).to be_a(Branch)

      standalone_atm = create(:atm_machine, branch: nil)
      expect(standalone_atm.branch).to be_nil
      expect(standalone_atm).to be_valid
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      atm = create(:atm_machine, status: 'active')
      expect(atm.active?).to be true

      atm.update(status: 'maintenance')
      expect(atm.maintenance?).to be true
    end

    it 'defines location_type enum' do
      atm = create(:atm_machine, location_type: 'supermarket')
      expect(atm.supermarket?).to be true

      atm.update(location_type: 'mall')
      expect(atm.mall?).to be true
    end
  end

  describe 'scopes' do
    let!(:active_atm) { create(:atm_machine, status: 'active', cash_available: 1000) }
    let!(:maintenance_atm) { create(:atm_machine, status: 'maintenance') }
    let!(:no_cash_atm) { create(:atm_machine, status: 'active', cash_available: 0) }
    let!(:supermarket_atm) { create(:atm_machine, location_type: 'supermarket') }

    describe '.active' do
      it 'returns only active ATMs' do
        results = AtmMachine.active
        expect(results).to include(active_atm, no_cash_atm)
        expect(results).not_to include(maintenance_atm)
      end
    end

    describe '.out_of_service' do
      it 'returns ATMs that are out of service' do
        results = AtmMachine.out_of_service
        expect(results).to include(maintenance_atm)
        expect(results).not_to include(active_atm, no_cash_atm)
      end
    end

    describe '.with_cash' do
      it 'returns ATMs with available cash' do
        results = AtmMachine.with_cash
        expect(results).to include(active_atm)
        expect(results).not_to include(no_cash_atm)
      end
    end

    describe '.by_location_type' do
      it 'returns ATMs of the specified location type' do
        results = AtmMachine.by_location_type('supermarket')
        expect(results).to include(supermarket_atm)
      end
    end
  end

  describe 'instance methods' do
    let(:branch) { create(:branch) }
    let(:atm_with_branch) { create(:atm_machine,
      branch: branch,
      address: '456 Oak St',
      city: 'Boston',
      state: 'MA',
      zipcode: '02101',
      cash_available: 15000
    ) }
    let(:standalone_atm) { create(:atm_machine,
      branch: nil,
      location_type: 'supermarket',
      status: 'active',
      cash_available: 5000
    ) }

    describe '#full_address' do
      it 'returns the formatted full address' do
        expect(atm_with_branch.full_address).to eq('456 Oak St, Boston, MA 02101')
      end
    end

    describe '#operational?' do
      it 'returns true when ATM is active and has cash' do
        expect(atm_with_branch.operational?).to be true
      end

      it 'returns false when ATM has no cash' do
        atm_with_branch.update(cash_available: 0)
        expect(atm_with_branch.operational?).to be false
      end

      it 'returns false when ATM is not active' do
        atm_with_branch.update(status: 'maintenance')
        expect(atm_with_branch.operational?).to be false
      end
    end

    describe '#location_name' do
      it 'returns branch name when ATM belongs to a branch' do
        expect(atm_with_branch.location_name).to eq("#{branch.name} Branch")
      end

      it 'returns location type when ATM is standalone' do
        expect(standalone_atm.location_name).to eq('Supermarket Location')
      end
    end

    describe '#formatted_cash_available' do
      it 'returns formatted cash amount' do
        expect(atm_with_branch.formatted_cash_available).to eq('$15,000')
        expect(standalone_atm.formatted_cash_available).to eq('$5,000')
      end
    end

    describe '#status_display' do
      it 'returns human-readable status' do
        expect(create(:atm_machine, status: 'active').status_display).to eq('Active')
        expect(create(:atm_machine, status: 'out_of_service').status_display).to eq('Out of Service')
        expect(create(:atm_machine, status: 'maintenance').status_display).to eq('Under Maintenance')
        expect(create(:atm_machine, status: 'out_of_cash').status_display).to eq('Out of Cash')
        expect(create(:atm_machine, status: 'offline').status_display).to eq('Offline')
      end
    end
  end
end
