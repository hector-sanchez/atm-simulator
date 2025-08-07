require 'rails_helper'

RSpec.describe TransactionPresenter, type: :presenter do
  let(:customer) { create(:customer) }
  let(:account) { create(:account, customer: customer) }
  let(:card) { create(:card, account: account) }
  let(:atm_machine) { create(:atm_machine) }
  let(:transaction) { create(:transaction, card: card, atm_machine: atm_machine) }
  let(:presenter) { TransactionPresenter.new(transaction) }

  describe '#initialize' do
    it 'accepts a transaction object' do
      expect(presenter.transaction).to eq(transaction)
    end
  end

  describe 'delegation' do
    it 'delegates basic attributes to the transaction' do
      expect(presenter.id).to eq(transaction.id)
      expect(presenter.amount).to eq(transaction.amount)
      expect(presenter.transaction_type).to eq(transaction.transaction_type)
      expect(presenter.source).to eq(transaction.source)
      expect(presenter.status).to eq(transaction.status)
      expect(presenter.created_at).to eq(transaction.created_at)
      expect(presenter.reference_number).to eq(transaction.reference_number)
    end
  end

  describe 'date formatting methods' do
    let(:transaction) { create(:transaction, card: card, created_at: Time.zone.parse('2025-01-15 14:30:00')) }

    describe '#formatted_date' do
      it 'returns date in MM/DD/YYYY format' do
        expect(presenter.formatted_date).to eq('01/15/2025')
      end
    end

    describe '#formatted_time' do
      it 'returns time in 12-hour format' do
        expect(presenter.formatted_time).to eq('02:30 PM')
      end
    end

    describe '#formatted_datetime' do
      it 'returns combined date and time' do
        expect(presenter.formatted_datetime).to eq('01/15/2025 at 02:30 PM')
      end
    end
  end

  describe 'type display methods' do
    context 'for credit transaction' do
      let(:transaction) { create(:transaction, :credit, card: card) }

      describe '#type_icon' do
        it 'returns money emoji' do
          expect(presenter.type_icon).to eq('💰')
        end
      end

      describe '#type_display' do
        it 'returns humanized transaction type' do
          expect(presenter.type_display).to eq('Credit')
        end
      end

      describe '#type_css_class' do
        it 'returns transaction type for CSS' do
          expect(presenter.type_css_class).to eq('credit')
        end
      end
    end

    context 'for debit transaction' do
      let(:transaction) { create(:transaction, :debit, card: card) }

      describe '#type_icon' do
        it 'returns card emoji' do
          expect(presenter.type_icon).to eq('💳')
        end
      end

      describe '#type_display' do
        it 'returns humanized transaction type' do
          expect(presenter.type_display).to eq('Debit')
        end
      end

      describe '#type_css_class' do
        it 'returns transaction type for CSS' do
          expect(presenter.type_css_class).to eq('debit')
        end
      end
    end
  end

  describe '#source_display' do
    context 'for ATM transaction' do
      let(:transaction) { create(:transaction, :from_atm, card: card) }

      it 'returns humanized source' do
        expect(presenter.source_display).to eq('Atm')
      end
    end

    context 'for teller transaction' do
      let(:transaction) { create(:transaction, :from_teller, card: card) }

      it 'returns humanized source' do
        expect(presenter.source_display).to eq('Teller')
      end
    end
  end

  describe 'amount display methods' do
    let(:transaction) { create(:transaction, card: card, amount: 123.45) }

    describe '#formatted_amount' do
      it 'returns amount with 2 decimal places' do
        expect(presenter.formatted_amount).to eq('123.45')
      end
    end

    describe '#amount_with_sign' do
      context 'for credit transaction' do
        let(:transaction) { create(:transaction, :credit, card: card, amount: 100.50) }

        it 'returns amount with plus sign' do
          expect(presenter.amount_with_sign).to eq('+$100.50')
        end
      end

      context 'for debit transaction' do
        let(:transaction) { create(:transaction, :debit, card: card, amount: 75.25) }

        it 'returns amount with minus sign' do
          expect(presenter.amount_with_sign).to eq('-$75.25')
        end
      end
    end

    describe '#amount_css_class' do
      it 'returns transaction type for CSS' do
        expect(presenter.amount_css_class).to eq(transaction.transaction_type)
      end
    end
  end

  describe 'location display methods' do
    context 'with ATM machine' do
      let(:atm_machine) { create(:atm_machine, location_name: 'Downtown Branch', city: 'New York', state: 'NY') }
      let(:transaction) { create(:transaction, card: card, atm_machine: atm_machine) }

      describe '#location_name' do
        it 'returns ATM location name' do
          expect(presenter.location_name).to eq('Downtown Branch')
        end
      end

      describe '#location_address' do
        it 'returns ATM city and state' do
          expect(presenter.location_address).to eq('New York, NY')
        end
      end

      describe '#has_atm_location?' do
        it 'returns true' do
          expect(presenter.has_atm_location?).to be true
        end
      end
    end

    context 'without ATM machine (teller transaction)' do
      let(:transaction) { create(:transaction, card: card, atm_machine: nil) }

      describe '#location_name' do
        it 'returns teller transaction text' do
          expect(presenter.location_name).to eq('Teller Transaction')
        end
      end

      describe '#location_address' do
        it 'returns in-branch service text' do
          expect(presenter.location_address).to eq('In-Branch Service')
        end
      end

      describe '#has_atm_location?' do
        it 'returns false' do
          expect(presenter.has_atm_location?).to be false
        end
      end
    end
  end

  describe 'status display methods' do
    context 'for approved transaction' do
      let(:transaction) { create(:transaction, card: card, status: 'approved') }

      describe '#status_icon' do
        it 'returns checkmark emoji' do
          expect(presenter.status_icon).to eq('✅')
        end
      end

      describe '#status_display' do
        it 'returns humanized status' do
          expect(presenter.status_display).to eq('Approved')
        end
      end

      describe '#status_css_class' do
        it 'returns status for CSS' do
          expect(presenter.status_css_class).to eq('approved')
        end
      end
    end

    context 'for denied transaction' do
      let(:transaction) { create(:transaction, card: card, status: 'denied') }

      describe '#status_icon' do
        it 'returns X emoji' do
          expect(presenter.status_icon).to eq('❌')
        end
      end

      describe '#status_display' do
        it 'returns humanized status' do
          expect(presenter.status_display).to eq('Denied')
        end
      end

      describe '#status_css_class' do
        it 'returns status for CSS' do
          expect(presenter.status_css_class).to eq('denied')
        end
      end
    end
  end

  describe 'CSS class methods' do
    let(:transaction) { create(:transaction, :credit, card: card, status: 'approved') }

    describe '#row_css_class' do
      it 'returns transaction row CSS class' do
        expect(presenter.row_css_class).to eq('transaction-row credit')
      end
    end

    describe '#type_badge_css_class' do
      it 'returns type badge CSS class' do
        expect(presenter.type_badge_css_class).to eq('type-badge credit')
      end
    end

    describe '#status_badge_css_class' do
      it 'returns status badge CSS class' do
        expect(presenter.status_badge_css_class).to eq('status-badge approved')
      end
    end
  end

  describe 'convenience methods' do
    describe '#approved?' do
      it 'returns true for approved transaction' do
        transaction = create(:transaction, card: card, status: 'approved')
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.approved?).to be true
      end

      it 'returns false for non-approved transaction' do
        transaction = create(:transaction, card: card, status: 'denied')
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.approved?).to be false
      end
    end

    describe '#denied?' do
      it 'returns true for denied transaction' do
        transaction = create(:transaction, card: card, status: 'denied')
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.denied?).to be true
      end

      it 'returns false for non-denied transaction' do
        transaction = create(:transaction, card: card, status: 'approved')
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.denied?).to be false
      end
    end

    describe '#credit?' do
      it 'returns true for credit transaction' do
        transaction = create(:transaction, :credit, card: card)
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.credit?).to be true
      end

      it 'returns false for debit transaction' do
        transaction = create(:transaction, :debit, card: card)
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.credit?).to be false
      end
    end

    describe '#debit?' do
      it 'returns true for debit transaction' do
        transaction = create(:transaction, :debit, card: card)
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.debit?).to be true
      end

      it 'returns false for credit transaction' do
        transaction = create(:transaction, :credit, card: card)
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.debit?).to be false
      end
    end

    describe '#from_atm?' do
      it 'returns true for ATM transaction' do
        transaction = create(:transaction, :from_atm, card: card)
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.from_atm?).to be true
      end

      it 'returns false for teller transaction' do
        transaction = create(:transaction, :from_teller, card: card)
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.from_atm?).to be false
      end
    end

    describe '#from_teller?' do
      it 'returns true for teller transaction' do
        transaction = create(:transaction, :from_teller, card: card)
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.from_teller?).to be true
      end

      it 'returns false for ATM transaction' do
        transaction = create(:transaction, :from_atm, card: card)
        presenter = TransactionPresenter.new(transaction)
        expect(presenter.from_teller?).to be false
      end
    end
  end
end
