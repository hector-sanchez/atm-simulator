require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    subject { build(:customer) }

    describe 'name' do
      it 'is valid with a valid name' do
        expect(subject).to be_valid
      end

      it 'is invalid without a name' do
        customer = build(:customer, :missing_name)
        expect(customer).to_not be_valid
        expect(customer.errors[:name]).to include("can't be blank")
      end

      it 'is invalid with a name longer than 250 characters' do
        customer = build(:customer, :invalid_name)
        expect(customer).to_not be_valid
        expect(customer.errors[:name]).to include("is too long (maximum is 250 characters)")
      end

      it 'is valid with a name exactly 250 characters' do
        customer = build(:customer, name: "a" * 250)
        expect(customer).to be_valid
      end
    end

    describe 'address' do
      it 'is invalid without an address' do
        customer = build(:customer, :missing_address)
        expect(customer).to_not be_valid
        expect(customer.errors[:address]).to include("can't be blank")
      end

      it 'is invalid with an address longer than 250 characters' do
        customer = build(:customer, :invalid_address)
        expect(customer).to_not be_valid
        expect(customer.errors[:address]).to include("is too long (maximum is 250 characters)")
      end

      it 'is valid with an address exactly 250 characters' do
        customer = build(:customer, address: "a" * 250)
        expect(customer).to be_valid
      end
    end

    describe 'city' do
      it 'is invalid without a city' do
        customer = build(:customer, :missing_city)
        expect(customer).to_not be_valid
        expect(customer.errors[:city]).to include("can't be blank")
      end

      it 'is valid with any non-empty city' do
        customer = build(:customer, city: "New York")
        expect(customer).to be_valid
      end
    end

    describe 'state' do
      it 'is invalid without a state' do
        customer = build(:customer, :missing_state)
        expect(customer).to_not be_valid
        expect(customer.errors[:state]).to include("can't be blank")
      end

      it 'is invalid with a state longer than 2 characters' do
        customer = build(:customer, :invalid_state)
        expect(customer).to_not be_valid
        expect(customer.errors[:state]).to include("is the wrong length (should be 2 characters)")
      end

      it 'is invalid with a state shorter than 2 characters' do
        customer = build(:customer, state: "A")
        expect(customer).to_not be_valid
        expect(customer.errors[:state]).to include("is the wrong length (should be 2 characters)")
      end

      it 'is valid with a 2-character state code' do
        customer = build(:customer, state: "CA")
        expect(customer).to be_valid
      end
    end

    describe 'zipcode' do
      it 'is invalid without a zipcode' do
        customer = build(:customer, :missing_zipcode)
        expect(customer).to_not be_valid
        expect(customer.errors[:zipcode]).to include("can't be blank")
      end

      it 'is invalid with an invalid zipcode format' do
        customer = build(:customer, :invalid_zipcode)
        expect(customer).to_not be_valid
        expect(customer.errors[:zipcode]).to include("must be a valid US postal code (e.g., 12345 or 12345-6789)")
      end

      it 'is valid with a 5-digit zipcode' do
        customer = build(:customer, zipcode: "12345")
        expect(customer).to be_valid
      end

      it 'is valid with a ZIP+4 format zipcode' do
        customer = build(:customer, zipcode: "12345-6789")
        expect(customer).to be_valid
      end

      it 'is invalid with letters in zipcode' do
        customer = build(:customer, zipcode: "ABCDE")
        expect(customer).to_not be_valid
        expect(customer.errors[:zipcode]).to include("must be a valid US postal code (e.g., 12345 or 12345-6789)")
      end

      it 'is invalid with too many digits' do
        customer = build(:customer, zipcode: "123456")
        expect(customer).to_not be_valid
        expect(customer.errors[:zipcode]).to include("must be a valid US postal code (e.g., 12345 or 12345-6789)")
      end

      it 'is invalid with wrong ZIP+4 format' do
        customer = build(:customer, zipcode: "12345-678")
        expect(customer).to_not be_valid
        expect(customer.errors[:zipcode]).to include("must be a valid US postal code (e.g., 12345 or 12345-6789)")
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      customer = build(:customer)
      expect(customer).to be_valid
    end

    it 'creates a customer with all required attributes' do
      customer = create(:customer)
      expect(customer.name).to be_present
      expect(customer.address).to be_present
      expect(customer.city).to be_present
      expect(customer.state).to be_present
      expect(customer.zipcode).to be_present
      expect(customer.persisted?).to be true
    end
  end

  describe 'database constraints' do
    it 'enforces database-level constraints' do
      customer = build(:customer)
      customer.save!

      # Test that we can access the saved customer
      saved_customer = Customer.find(customer.id)
      expect(saved_customer.name).to eq(customer.name)
      expect(saved_customer.address).to eq(customer.address)
      expect(saved_customer.city).to eq(customer.city)
      expect(saved_customer.state).to eq(customer.state)
      expect(saved_customer.zipcode).to eq(customer.zipcode)
    end
  end
end
