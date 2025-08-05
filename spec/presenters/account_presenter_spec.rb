require 'rails_helper'

RSpec.describe AccountPresenter, type: :presenter do
  let(:customer) { create(:customer, name: "Jane Smith") }
  let(:account) do
    create(:account,
      customer: customer,
      account_number: "9876543210987654",
      account_type: "savings",
      balance: 2750.50
    )
  end
  let(:presenter) { described_class.new(account) }

  describe '#formatted_account_number' do
    it 'returns masked account number with last four digits' do
      expect(presenter.formatted_account_number).to eq("****7654")
    end

    context 'when account_number is blank' do
      before { allow(account).to receive(:account_number).and_return(nil) }

      it 'returns default masked number' do
        expect(presenter.formatted_account_number).to eq("****0000")
      end
    end

    context 'when account_number is empty string' do
      before { allow(account).to receive(:account_number).and_return("") }

      it 'returns default masked number' do
        expect(presenter.formatted_account_number).to eq("****0000")
      end
    end
  end

  describe '#formatted_balance' do
    it 'returns currency formatted balance' do
      expect(presenter.formatted_balance).to eq("$2,750.50")
    end

    context 'with zero balance' do
      before { account.update!(balance: 0.00) }

      it 'returns formatted zero' do
        expect(presenter.formatted_balance).to eq("$0.00")
      end
    end

    context 'with large balance' do
      before { account.update!(balance: 1_234_567.89) }

      it 'returns formatted large amount' do
        expect(presenter.formatted_balance).to eq("$1,234,567.89")
      end
    end
  end

  describe '#account_type_display' do
    it 'returns capitalized account type' do
      expect(presenter.account_type_display).to eq("Savings")
    end

    context 'with checking account' do
      before { account.update!(account_type: "checking") }

      it 'returns capitalized checking' do
        expect(presenter.account_type_display).to eq("Checking")
      end
    end
  end

  describe '#account_type_titleized' do
    it 'returns titleized account type' do
      expect(presenter.account_type_titleized).to eq("Savings")
    end

    context 'with checking account type' do
      before { account.update!(account_type: "checking") }

      it 'returns titleized checking type' do
        expect(presenter.account_type_titleized).to eq("Checking")
      end
    end
  end

  describe 'delegation' do
    it 'delegates account_number to the account' do
      expect(presenter.account_number).to eq("9876543210987654")
    end

    it 'delegates account_type to the account' do
      expect(presenter.account_type).to eq("savings")
    end

    it 'delegates balance to the account' do
      expect(presenter.balance).to eq(2750.50)
    end

    it 'delegates customer to the account' do
      expect(presenter.customer).to eq(customer)
    end
  end

  describe 'integration with ActionController helpers' do
    it 'uses Rails number_to_currency helper' do
      expect(ActionController::Base.helpers).to receive(:number_to_currency).with(2750.50).and_return("$2,750.50")
      presenter.formatted_balance
    end
  end
end
