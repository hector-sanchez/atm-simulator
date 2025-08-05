require 'rails_helper'

RSpec.describe Branch, type: :model do
  describe 'validations' do
    let(:branch) { build(:branch) }

    it 'validates presence of name' do
      branch.name = nil
      expect(branch).not_to be_valid
      expect(branch.errors[:name]).to include("can't be blank")
    end

    it 'validates length of name' do
      branch.name = 'a' * 251
      expect(branch).not_to be_valid
      expect(branch.errors[:name]).to include('is too long (maximum is 250 characters)')
    end

    it 'validates presence of address' do
      branch.address = nil
      expect(branch).not_to be_valid
      expect(branch.errors[:address]).to include("can't be blank")
    end

    it 'validates presence of city' do
      branch.city = nil
      expect(branch).not_to be_valid
      expect(branch.errors[:city]).to include("can't be blank")
    end

    it 'validates presence and format of state' do
      branch.state = nil
      expect(branch).not_to be_valid
      expect(branch.errors[:state]).to include("can't be blank")

      branch.state = 'ABC'
      expect(branch).not_to be_valid
      expect(branch.errors[:state]).to include('is the wrong length (should be 2 characters)')
    end

    it 'validates zipcode format' do
      branch.zipcode = '12345'
      expect(branch).to be_valid

      branch.zipcode = '12345-6789'
      expect(branch).to be_valid

      branch.zipcode = 'invalid'
      expect(branch).not_to be_valid
      expect(branch.errors[:zipcode]).to include('must be a valid US postal code')
    end

    it 'validates phone format' do
      branch.phone = '1234567890'
      expect(branch).to be_valid

      branch.phone = '123-456-7890'
      expect(branch).not_to be_valid
      expect(branch.errors[:phone]).to include('must be a 10-digit phone number')
    end

    it 'validates branch_code presence, uniqueness and format' do
      branch.branch_code = nil
      expect(branch).not_to be_valid
      expect(branch.errors[:branch_code]).to include("can't be blank")

      branch.branch_code = 'A1B2'
      branch.save!

      duplicate_branch = build(:branch, branch_code: 'A1B2')
      expect(duplicate_branch).not_to be_valid
      expect(duplicate_branch.errors[:branch_code]).to include('has already been taken')
    end
  end

  describe 'associations' do
    let(:branch) { create(:branch) }

    it 'has many atm_machines' do
      atm1 = create(:atm_machine, branch: branch)
      atm2 = create(:atm_machine, branch: branch)

      expect(branch.atm_machines).to include(atm1, atm2)
    end

    it 'nullifies atm_machines when branch is destroyed' do
      atm = create(:atm_machine, branch: branch)
      branch.destroy

      atm.reload
      expect(atm.branch).to be_nil
    end
  end

  describe 'scopes' do
    let!(:branch_ny) { create(:branch, state: 'NY', city: 'New York') }
    let!(:branch_ca) { create(:branch, state: 'CA', city: 'Los Angeles') }
    let!(:branch_ny2) { create(:branch, state: 'NY', city: 'Buffalo') }

    describe '.by_state' do
      it 'returns branches in the specified state' do
        expect(Branch.by_state('NY')).to contain_exactly(branch_ny, branch_ny2)
        expect(Branch.by_state('CA')).to contain_exactly(branch_ca)
      end
    end

    describe '.by_city' do
      it 'returns branches in the specified city' do
        expect(Branch.by_city('New York')).to contain_exactly(branch_ny)
        expect(Branch.by_city('Los Angeles')).to contain_exactly(branch_ca)
      end
    end
  end

  describe 'instance methods' do
    let(:branch) { create(:branch,
      address: '123 Main St',
      city: 'New York',
      state: 'NY',
      zipcode: '10001',
      phone: '2125551234'
    ) }

    describe '#full_address' do
      it 'returns the formatted full address' do
        expect(branch.full_address).to eq('123 Main St, New York, NY 10001')
      end
    end

    describe '#formatted_phone' do
      it 'returns the formatted phone number' do
        expect(branch.formatted_phone).to eq('(212) 555-1234')
      end
    end

    describe '#atm_count' do
      it 'returns the number of ATMs at the branch' do
        expect(branch.atm_count).to eq(0)

        create(:atm_machine, branch: branch)
        create(:atm_machine, branch: branch)

        expect(branch.atm_count).to eq(2)
      end
    end
  end
end
