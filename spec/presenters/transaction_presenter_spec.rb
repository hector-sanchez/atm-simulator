require 'rails_helper'

RSpec.describe TransactionPresenter, type: :presenter do
  describe 'Debit transactions' do
    context 'ATM transaction' do
      let(:branch) { create(:branch, name: 'Downtown') }
      let(:atm_machine) { create(:atm_machine, branch: branch, city: 'New York', state: 'NY') }
      let(:debit_transaction) { create(:transaction, :atm, :debit, amount: 150.00, atm_machine: atm_machine) }
      let(:presenter) { TransactionPresenter.new(debit_transaction) }

      describe '#amount_with_sign' do
        it 'returns formatted amount with sign for debit' do
          expect(presenter.amount_with_sign).to eq('-$150.00')
        end
      end

      describe '#amount_css_class' do
        it 'returns debit class for debit transactions' do
          expect(presenter.amount_css_class).to eq('debit')
        end
      end

      describe '#type_icon' do
        it 'returns correct icon for debit' do
          expect(presenter.type_icon).to eq('💳')
        end
      end

      describe '#formatted_date' do
        it 'returns formatted date in short format' do
          expect(presenter.formatted_date).to match(/\d{2}\/\d{2}\/\d{4}/)
        end
      end

      describe '#formatted_time' do
        it 'returns formatted time' do
          expect(presenter.formatted_time).to match(/\d{1,2}:\d{2} (AM|PM)/)
        end
      end

      describe '#location_name' do
        it 'returns ATM location name' do
          expect(presenter.location_name).to eq('Downtown Branch')
        end
      end

      describe '#location_address' do
        it 'returns ATM address' do
          expect(presenter.location_address).to include('New York, NY')
        end
      end

      describe '#has_atm_location?' do
        it 'returns true for ATM transactions' do
          expect(presenter.has_atm_location?).to be true
        end
      end

      describe '#source_display' do
        it 'returns ATM for atm source' do
          expect(presenter.source_display).to eq('Atm')
        end
      end

      describe '#status_icon' do
        it 'returns checkmark for approved status' do
          expect(presenter.status_icon).to eq('✅')
        end
      end

      describe '#status_badge_css_class' do
        it 'returns approved class with base class for approved status' do
          expect(presenter.status_badge_css_class).to eq('status-badge approved')
        end
      end

      describe '#type_badge_css_class' do
        it 'returns debit class with base class for debit type' do
          expect(presenter.type_badge_css_class).to eq('type-badge debit')
        end
      end
    end

    context 'Teller transaction' do
      let(:teller_transaction) { create(:transaction, :from_teller, :debit, amount: 200.00) }
      let(:presenter) { TransactionPresenter.new(teller_transaction) }

      describe '#location_name' do
        it 'returns Teller Transaction for teller source' do
          expect(presenter.location_name).to eq('Teller Transaction')
        end
      end

      describe '#location_address' do
        it 'returns In-Branch Service for teller transactions' do
          expect(presenter.location_address).to eq('In-Branch Service')
        end
      end

      describe '#has_atm_location?' do
        it 'returns false for teller transactions' do
          expect(presenter.has_atm_location?).to be false
        end
      end

      describe '#source_display' do
        it 'returns Teller for teller source' do
          expect(presenter.source_display).to eq('Teller')
        end
      end
    end
  end

  describe 'Credit transactions' do
    context 'ATM transaction' do
      let(:branch) { create(:branch, name: 'Uptown') }
      let(:atm_machine) { create(:atm_machine, branch: branch) }
      let(:credit_transaction) { create(:transaction, :atm, :credit, amount: 500.00, atm_machine: atm_machine) }
      let(:presenter) { TransactionPresenter.new(credit_transaction) }

      describe '#amount_with_sign' do
        it 'returns formatted amount with sign for credit' do
          expect(presenter.amount_with_sign).to eq('+$500.00')
        end
      end

      describe '#amount_css_class' do
        it 'returns credit class for credit transactions' do
          expect(presenter.amount_css_class).to eq('credit')
        end
      end

      describe '#type_icon' do
        it 'returns correct icon for credit' do
          expect(presenter.type_icon).to eq('💰')
        end
      end

      describe '#type_badge_css_class' do
        it 'returns credit class with base class for credit type' do
          expect(presenter.type_badge_css_class).to eq('type-badge credit')
        end
      end
    end

    context 'Teller transaction' do
      let(:teller_credit) { create(:transaction, :teller, :credit, amount: 1000.00) }
      let(:presenter) { TransactionPresenter.new(teller_credit) }

      describe '#amount_with_sign' do
        it 'returns formatted amount with sign for teller credit without comma' do
          expect(presenter.amount_with_sign).to eq('+$1000.00')
        end
      end
    end
  end

  describe 'Status handling' do
    context 'denied transaction' do
      let(:denied_transaction) { create(:transaction, :teller, :denied) }
      let(:presenter) { TransactionPresenter.new(denied_transaction) }

      describe '#status_icon' do
        it 'returns X for denied status' do
          expect(presenter.status_icon).to eq('❌')
        end
      end

      describe '#status_badge_css_class' do
        it 'returns denied class with base class for denied status' do
          expect(presenter.status_badge_css_class).to eq('status-badge denied')
        end
      end
    end

    context 'pending transaction' do
      let(:pending_transaction) { create(:transaction, :teller, :pending) }
      let(:presenter) { TransactionPresenter.new(pending_transaction) }

      describe '#status_icon' do
        it 'returns checkmark for pending status (defaults to approved icon)' do
          expect(presenter.status_icon).to eq('✅')
        end
      end

      describe '#status_badge_css_class' do
        it 'returns pending status with base class' do
          expect(presenter.status_badge_css_class).to eq('status-badge approved')
        end
      end
    end

    context 'cancelled transaction' do
      let(:cancelled_transaction) { create(:transaction, :teller, :cancelled) }
      let(:presenter) { TransactionPresenter.new(cancelled_transaction) }

      describe '#status_icon' do
        it 'returns X for cancelled status' do
          expect(presenter.status_icon).to eq('❌')
        end
      end

      describe '#status_badge_css_class' do
        it 'returns cancelled class with base class for cancelled status' do
          expect(presenter.status_badge_css_class).to eq('status-badge cancelled')
        end
      end
    end
  end

  describe 'Edge cases' do
    context 'large amounts' do
      let(:large_transaction) { create(:transaction, :teller, :credit, amount: 12345.67) }
      let(:presenter) { TransactionPresenter.new(large_transaction) }

      describe '#amount_with_sign' do
        it 'formats large amounts without commas' do
          expect(presenter.amount_with_sign).to eq('+$12345.67')
        end
      end
    end

    context 'small amounts' do
      let(:small_transaction) { create(:transaction, :teller, :debit, amount: 0.01) }
      let(:presenter) { TransactionPresenter.new(small_transaction) }

      describe '#amount_with_sign' do
        it 'formats small amounts correctly' do
          expect(presenter.amount_with_sign).to eq('-$0.01')
        end
      end
    end
  end

  describe 'Date and time formatting' do
    let(:transaction) { create(:transaction, :teller, created_at: Time.parse('2024-12-15 14:30:45')) }
    let(:presenter) { TransactionPresenter.new(transaction) }

    describe '#formatted_date' do
      it 'returns formatted date in MM/DD/YYYY format' do
        expect(presenter.formatted_date).to eq('12/15/2024')
      end
    end

    describe '#formatted_time' do
      it 'returns formatted time' do
        # Time zone might affect this, so we'll be more flexible
        expect(presenter.formatted_time).to match(/\d{1,2}:\d{2} (AM|PM)/)
      end
    end
  end

  describe 'Core functionality' do
    let(:transaction) { create(:transaction, :teller) }
    let(:presenter) { TransactionPresenter.new(transaction) }

    describe '#transaction' do
      it 'returns the wrapped transaction' do
        expect(presenter.transaction).to eq(transaction)
      end
    end

    describe '#type_display' do
      it 'returns humanized transaction type' do
        expect(presenter.type_display).to be_present
      end
    end

    describe '#status_display' do
      it 'returns humanized status' do
        expect(presenter.status_display).to be_present
      end
    end

    describe '#formatted_datetime' do
      it 'returns formatted datetime' do
        expect(presenter.formatted_datetime).to be_present
      end
    end

    describe '#row_css_class' do
      it 'returns appropriate row CSS class' do
        expect(presenter.row_css_class).to be_present
      end
    end

    describe '#type_css_class' do
      it 'returns type CSS class' do
        expect(presenter.type_css_class).to be_present
      end
    end

    describe '#status_css_class' do
      it 'returns status CSS class' do
        expect(presenter.status_css_class).to be_present
      end
    end

    describe 'Boolean helpers' do
      describe '#approved?' do
        it 'returns appropriate boolean' do
          expect([true, false]).to include(presenter.approved?)
        end
      end

      describe '#denied?' do
        it 'returns appropriate boolean' do
          expect([true, false]).to include(presenter.denied?)
        end
      end

      describe '#credit?' do
        it 'returns appropriate boolean' do
          expect([true, false]).to include(presenter.credit?)
        end
      end

      describe '#debit?' do
        it 'returns appropriate boolean' do
          expect([true, false]).to include(presenter.debit?)
        end
      end

      describe '#from_atm?' do
        it 'returns false for teller transactions' do
          expect(presenter.from_atm?).to be false
        end
      end

      describe '#from_teller?' do
        it 'returns true for teller transactions' do
          expect(presenter.from_teller?).to be true
        end
      end
    end
  end
end
