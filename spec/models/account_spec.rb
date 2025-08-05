require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:customer) { create(:customer) }
  let(:account) { create(:account, customer: customer) }

  describe 'associations' do
    it 'belongs to customer' do
      expect(account.customer).to eq(customer)
    end
  end

  describe 'validations' do
    it 'validates presence of account_number' do
      account = build(:account, account_number: nil)
      expect(account).not_to be_valid
      expect(account.errors[:account_number]).to include("can't be blank")
    end

    it 'validates uniqueness of account_number' do
      create(:account, account_number: '1234567890')
      account = build(:account, account_number: '1234567890')
      expect(account).not_to be_valid
      expect(account.errors[:account_number]).to include('has already been taken')
    end

    it 'validates presence of balance' do
      account = build(:account, balance: nil)
      expect(account).not_to be_valid
      expect(account.errors[:balance]).to include("can't be blank")
    end

    it 'validates balance is greater than or equal to 0' do
      account = build(:account, balance: -1.00)
      expect(account).not_to be_valid
      expect(account.errors[:balance]).to include('must be greater than or equal to 0')
    end

    it 'allows balance of 0' do
      account = build(:account, balance: 0.00)
      expect(account).to be_valid
    end

    it 'validates presence of account_type' do
      account = build(:account, account_type: nil)
      expect(account).not_to be_valid
      expect(account.errors[:account_type]).to include("can't be blank")
    end

    it 'validates account_type inclusion in allowed types' do
      account = build(:account, account_type: 'invalid')
      expect(account).not_to be_valid
      expect(account.errors[:account_type]).to include('is not included in the list')

      %w[checking savings].each do |type|
        account = build(:account, account_type: type)
        expect(account).to be_valid
      end
    end
  end

  describe 'constants' do
    it 'defines account types' do
      expect(Account::ACCOUNT_TYPES).to eq(%w[checking savings])
    end
  end

  describe '#sufficient_funds?' do
    let(:account) { create(:account, balance: 100.00) }

    it 'returns true when balance is sufficient' do
      expect(account.sufficient_funds?(50.00)).to be true
    end

    it 'returns true when amount equals balance' do
      expect(account.sufficient_funds?(100.00)).to be true
    end

    it 'returns false when balance is insufficient' do
      expect(account.sufficient_funds?(150.00)).to be false
    end
  end

  describe '#debit!' do
    let(:account) { create(:account, balance: 100.00) }

    it 'reduces balance by the specified amount' do
      account.debit!(25.00)
      expect(account.reload.balance).to eq(75.00)
    end

    it 'raises error when insufficient funds' do
      expect {
        account.debit!(150.00)
      }.to raise_error(ArgumentError, 'Insufficient funds')
    end

    it 'does not change balance when transaction fails' do
      expect {
        account.debit!(150.00)
      }.to raise_error(ArgumentError)
      expect(account.reload.balance).to eq(100.00)
    end
  end

  describe '#credit!' do
    let(:account) { create(:account, balance: 100.00) }

    it 'increases balance by the specified amount' do
      account.credit!(25.00)
      expect(account.reload.balance).to eq(125.00)
    end

    it 'raises error for non-positive amounts' do
      expect {
        account.credit!(0)
      }.to raise_error(ArgumentError, 'Amount must be positive')

      expect {
        account.credit!(-10.00)
      }.to raise_error(ArgumentError, 'Amount must be positive')
    end

    it 'does not change balance when transaction fails' do
      expect {
        account.credit!(-10.00)
      }.to raise_error(ArgumentError)
      expect(account.reload.balance).to eq(100.00)
    end
  end

  describe 'factory traits' do
    it 'creates checking account' do
      account = create(:account, :checking)
      expect(account.account_type).to eq('checking')
    end

    it 'creates savings account' do
      account = create(:account, :savings)
      expect(account.account_type).to eq('savings')
    end

    it 'creates zero balance account' do
      account = create(:account, :zero_balance)
      expect(account.balance).to eq(0.00)
    end
  end
end
