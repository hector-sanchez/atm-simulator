require 'rails_helper'

RSpec.describe TransactionPresenter, type: :presenter do
  describe 'Debit transactions' do
    context 'ATM transaction' do
      let(:branch) { create(:branch, name: 'Downtown') }
      let(:atm_machine) { create(:atm_machine, branch: branch, city: 'New York', state: 'NY') }
      let(:debit_transaction) { create(:transaction, :atm, :debit, amount: 150.00, atm_machine: atm_machine) }
      let(:presenter) { TransactionPresenter.new(debit_transaction) }

      describe '#formatted_amount' do
        it 'returns formatted amount for debit' do
          expect(presenter.formatted_amount).to eq('-$150.00')
        end
      end

      describe '#amount_css_class' do
        it 'returns debit class for debit transactions' do
          expect(presenter.amount_css_class).to eq('debit')
        end
      end

      describe '#transaction_icon' do
        it 'returns correct icon for debit' do
          expect(presenter.transaction_icon).to eq('💳')
        end
      end

      describe '#transaction_sign' do
        it 'returns minus sign for debit' do
          expect(presenter.transaction_sign).to eq('-')
        end
      end

      describe '#friendly_date' do
        it 'returns formatted date' do
          expect(presenter.friendly_date).to match(/\w+ \d{1,2}, \d{4}/)
        end
      end

      describe '#friendly_time' do
        it 'returns formatted time' do
          expect(presenter.friendly_time).to match(/\d{1,2}:\d{2} (AM|PM)/)
        end
      end

      describe '#location_name' do
        it 'returns ATM location name' do
          expect(presenter.location_name).to eq('Downtown Branch')
        end
      end

      describe '#location_address' do
        it 'returns ATM address' do
          expect(presenter.location_address).to eq(atm_machine.full_address)
        end
      end

      describe '#has_atm_location?' do
        it 'returns true for ATM transactions' do
          expect(presenter.has_atm_location?).to be true
        end
      end

      describe '#source_display' do
        it 'returns ATM for atm source' do
          expect(presenter.source_display).to eq('ATM')
        end
      end

      describe '#status_icon' do
        it 'returns checkmark for approved status' do
          expect(presenter.status_icon).to eq('✓')
        end
      end

      describe '#status_badge_class' do
        it 'returns approved class for approved status' do
          expect(presenter.status_badge_class).to eq('approved')
        end
      end

      describe '#type_badge_class' do
        it 'returns debit class for debit type' do
          expect(presenter.type_badge_class).to eq('debit')
        end
      end
    end

    context 'Teller transaction' do
      let(:teller_transaction) { create(:transaction, :teller, :debit, amount: 200.00) }
      let(:presenter) { TransactionPresenter.new(teller_transaction) }

      describe '#location_name' do
        it 'returns Teller Transaction for teller source' do
          expect(presenter.location_name).to eq('Teller Transaction')
        end
      end

      describe '#location_address' do
        it 'returns bank branch address for teller transactions' do
          expect(presenter.location_address).to eq('Local Bank Branch')
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

      describe '#formatted_amount' do
        it 'returns formatted amount for credit' do
          expect(presenter.formatted_amount).to eq('+$500.00')
        end
      end

      describe '#amount_css_class' do
        it 'returns credit class for credit transactions' do
          expect(presenter.amount_css_class).to eq('credit')
        end
      end

      describe '#transaction_icon' do
        it 'returns correct icon for credit' do
          expect(presenter.transaction_icon).to eq('💰')
        end
      end

      describe '#transaction_sign' do
        it 'returns plus sign for credit' do
          expect(presenter.transaction_sign).to eq('+')
        end
      end

      describe '#type_badge_class' do
        it 'returns credit class for credit type' do
          expect(presenter.type_badge_class).to eq('credit')
        end
      end
    end

    context 'Teller transaction' do
      let(:teller_credit) { create(:transaction, :teller, :credit, amount: 1000.00) }
      let(:presenter) { TransactionPresenter.new(teller_credit) }

      describe '#formatted_amount' do
        it 'returns formatted amount for teller credit' do
          expect(presenter.formatted_amount).to eq('+$1,000.00')
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
          expect(presenter.status_icon).to eq('✗')
        end
      end

      describe '#status_badge_class' do
        it 'returns denied class for denied status' do
          expect(presenter.status_badge_class).to eq('denied')
        end
      end
    end

    context 'pending transaction' do
      let(:pending_transaction) { create(:transaction, :teller, :pending) }
      let(:presenter) { TransactionPresenter.new(pending_transaction) }

      describe '#status_icon' do
        it 'returns clock for pending status' do
          expect(presenter.status_icon).to eq('⏳')
        end
      end

      describe '#status_badge_class' do
        it 'returns pending class for pending status' do
          expect(presenter.status_badge_class).to eq('pending')
        end
      end
    end

    context 'cancelled transaction' do
      let(:cancelled_transaction) { create(:transaction, :teller, :cancelled) }
      let(:presenter) { TransactionPresenter.new(cancelled_transaction) }

      describe '#status_icon' do
        it 'returns dash for cancelled status' do
          expect(presenter.status_icon).to eq('—')
        end
      end

      describe '#status_badge_class' do
        it 'returns cancelled class for cancelled status' do
          expect(presenter.status_badge_class).to eq('cancelled')
        end
      end
    end
  end

  describe 'Edge cases' do
    context 'large amounts' do
      let(:large_transaction) { create(:transaction, :teller, :credit, amount: 12345.67) }
      let(:presenter) { TransactionPresenter.new(large_transaction) }

      describe '#formatted_amount' do
        it 'formats large amounts with commas' do
          expect(presenter.formatted_amount).to eq('+$12,345.67')
        end
      end
    end

    context 'small amounts' do
      let(:small_transaction) { create(:transaction, :teller, :debit, amount: 0.01) }
      let(:presenter) { TransactionPresenter.new(small_transaction) }

      describe '#formatted_amount' do
        it 'formats small amounts correctly' do
          expect(presenter.formatted_amount).to eq('-$0.01')
        end
      end
    end
  end

  describe 'Date and time formatting' do
    let(:transaction) { create(:transaction, :teller, created_at: Time.parse('2024-12-15 14:30:45')) }
    let(:presenter) { TransactionPresenter.new(transaction) }

    describe '#friendly_date' do
      it 'returns formatted date' do
        expect(presenter.friendly_date).to eq('December 15, 2024')
      end
    end

    describe '#friendly_time' do
      it 'returns formatted time' do
        expect(presenter.friendly_time).to eq('2:30 PM')
      end
    end
  end
end
