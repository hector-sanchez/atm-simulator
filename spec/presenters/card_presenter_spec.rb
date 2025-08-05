require 'rails_helper'

RSpec.describe CardPresenter, type: :presenter do
  let(:customer) { create(:customer, name: "John Doe Smith") }
  let(:account) { create(:account, customer: customer, account_number: "1234567890123456", account_type: "checking", balance: 1500.00) }
  let(:card) do
    create(:card,
      account: account,
      card_number: "4532015112830366",
      last_four_digits: "0366",
      card_type: "visa",
      status: "active",
      expiration_date: Date.new(2027, 12, 31)
    )
  end
  let(:presenter) { described_class.new(card) }

  describe '#formatted_display' do
    it 'returns masked card number with last four digits' do
      expect(presenter.formatted_display).to eq("****0366")
    end

    context 'when last_four_digits is not available' do
      before { allow(card).to receive(:respond_to?).with(:last_four_digits).and_return(false) }

      it 'falls back to extracting from card_number' do
        expect(presenter.formatted_display).to eq("****0366")
      end
    end

    context 'when card_number is blank' do
      before do
        allow(card).to receive(:respond_to?).and_return(true)  # Default response
        allow(card).to receive(:respond_to?).with(:last_four_digits).and_return(false)
        allow(card).to receive(:card_number).and_return(nil)
      end

      it 'returns default masked number' do
        expect(presenter.formatted_display).to eq("****0000")
      end
    end
  end

  describe '#formatted_expiration' do
    it 'formats expiration date as MM/YY' do
      expect(presenter.formatted_expiration).to eq("12/27")
    end
  end

  describe '#card_type_display' do
    it 'returns uppercase card type' do
      expect(presenter.card_type_display).to eq("VISA")
    end

    context 'with mastercard' do
      before { card.update!(card_type: "mastercard") }

      it 'returns uppercase mastercard' do
        expect(presenter.card_type_display).to eq("MASTERCARD")
      end
    end
  end

  describe '#status_display' do
    it 'returns titleized status' do
      expect(presenter.status_display).to eq("Active")
    end

    context 'with blocked status' do
      before { card.update!(status: "blocked") }

      it 'returns titleized blocked status' do
        expect(presenter.status_display).to eq("Blocked")
      end
    end
  end

  describe '#status_css_class' do
    it 'returns status-active for active status' do
      expect(presenter.status_css_class).to eq("status-active")
    end

    context 'with blocked status' do
      before { card.update!(status: "blocked") }

      it 'returns status-blocked' do
        expect(presenter.status_css_class).to eq("status-blocked")
      end
    end

    context 'with suspended status' do
      before { card.update!(status: "suspended") }

      it 'returns status-blocked' do
        expect(presenter.status_css_class).to eq("status-blocked")
      end
    end

    context 'with expired status' do
      before { card.update!(status: "expired") }

      it 'returns status-expired' do
        expect(presenter.status_css_class).to eq("status-expired")
      end
    end

    context 'with unknown status' do
      before { allow(card).to receive(:status).and_return("pending") }

      it 'returns status-unknown' do
        expect(presenter.status_css_class).to eq("status-unknown")
      end
    end
  end

  describe '#cardholder_name' do
    it 'returns uppercase cardholder name from card' do
      expect(presenter.cardholder_name).to eq("JOHN DOE")
    end
  end

  describe '#customer_first_name' do
    it 'returns first name from cardholder name' do
      expect(presenter.customer_first_name).to eq("John")
    end

    context 'with single cardholder name' do
      before { card.update!(cardholder_name: "Madonna") }

      it 'returns the single name' do
        expect(presenter.customer_first_name).to eq("Madonna")
      end
    end
  end

  describe 'delegation' do
    it 'delegates account to the card' do
      expect(presenter.account).to eq(account)
    end

    it 'delegates customer to the card' do
      expect(presenter.customer).to eq(customer)
    end

    it 'delegates card_type to the card' do
      expect(presenter.card_type).to eq("visa")
    end

    it 'delegates status to the card' do
      expect(presenter.status).to eq("active")
    end

    it 'delegates expiration_date to the card' do
      expect(presenter.expiration_date).to eq(Date.new(2027, 12, 31))
    end
  end
end
