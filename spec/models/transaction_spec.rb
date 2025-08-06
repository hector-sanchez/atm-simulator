require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:account) { create(:account, balance: 1000.00) }
  let(:card) { create(:card, account: account) }
  let(:atm_machine) { create(:atm_machine) }
  let(:transaction) { build(:transaction, card: card, atm_machine: atm_machine) }

  describe 'associations' do
    it 'belongs to card' do
      expect(transaction.card).to eq(card)
    end

    it 'delegates account access through card' do
      expect(transaction.account).to eq(card.account)
    end

    it 'belongs to atm_machine optionally' do
      saved_transaction = create(:transaction, :from_atm, card: card)
      expect(saved_transaction.atm_machine).to be_a(AtmMachine)

      teller_transaction = build(:transaction, :from_teller)
      teller_transaction.skip_auto_processing = true
      teller_transaction.card = card
      teller_transaction.save!
      expect(teller_transaction.atm_machine).to be_nil
    end
  end

  describe 'validations' do
    it 'validates presence of required fields' do
      transaction = build(:transaction,
        amount: nil,
        card: nil
      )
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include("can't be blank")
      expect(transaction.errors[:card]).to include("must exist")
    end

    it 'validates amount is positive' do
      transaction.amount = 0
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include('must be greater than 0')

      transaction.amount = -10.00
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include('must be greater than 0')
    end

    it 'validates reference_number format and uniqueness' do
      transaction.reference_number = '123'
      expect(transaction).not_to be_valid
      expect(transaction.errors[:reference_number]).to include('must be 10-20 alphanumeric characters')

      transaction.reference_number = 'TXN12345ABC'
      transaction.save!

      duplicate = build(:transaction, reference_number: 'TXN12345ABC', card: card)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:reference_number]).to include('has already been taken')
    end

    it 'requires ATM machine for ATM transactions' do
      transaction.source = 'atm'
      transaction.atm_machine = nil
      expect(transaction).not_to be_valid
      expect(transaction.errors[:atm_machine]).to include('is required for ATM transactions')
    end

    it 'validates card belongs to account' do
      other_account = create(:account)
      other_card = create(:card, account: other_account, card_number: '4532015112830999')

      transaction.card = other_card
      expect(transaction.account).to eq(other_account) # Should delegate correctly
    end
  end

  describe 'enums' do
    it 'defines transaction_type enum' do
      expect(Transaction.transaction_types).to eq({
        'credit' => 'credit',
        'debit' => 'debit'
      })
    end

    it 'defines source enum' do
      expect(Transaction.sources).to eq({
        'atm' => 'atm',
        'teller' => 'teller'
      })
    end

    it 'defines status enum' do
      expect(Transaction.statuses).to eq({
        'approved' => 'approved',
        'denied' => 'denied',
        'pending' => 'pending',
        'cancelled' => 'cancelled'
      })
    end
  end

  describe 'callbacks' do
    it 'generates reference number before validation' do
      transaction.reference_number = nil
      transaction.valid?
      expect(transaction.reference_number).to match(/\ATXN\d{8}[A-Z0-9]{6}\z/)
    end

    it 'sets default status to pending' do
      transaction.status = nil
      transaction.valid?
      expect(transaction.status).to eq('pending')
    end

    it 'processes transaction after create when pending' do
      expect_any_instance_of(Transaction).to receive(:process_transaction)
      transaction.save!
    end

    it 'skips processing when flag is set' do
      transaction.skip_auto_processing = true
      expect_any_instance_of(Transaction).not_to receive(:process_transaction)
      transaction.save!
    end
  end

  describe 'scopes' do
    let!(:approved_debit) {
      t = build(:transaction, :debit, card: card, status: 'approved')
      t.skip_auto_processing = true
      t.save!
      t
    }
    let!(:denied_credit) {
      t = build(:transaction, :credit, card: card, status: 'denied')
      t.skip_auto_processing = true
      t.save!
      t
    }
    let!(:pending_debit) {
      t = build(:transaction, :debit, card: card, status: 'pending')
      t.skip_auto_processing = true
      t.save!
      t
    }
    let!(:atm_transaction) {
      t = build(:transaction, :from_atm, card: card)
      t.skip_auto_processing = true
      t.save!
      t
    }
    let!(:teller_transaction) {
      t = build(:transaction, :from_teller, card: card)
      t.skip_auto_processing = true
      t.save!
      t
    }

    describe '.approved' do
      it 'returns only approved transactions' do
        results = Transaction.approved
        expect(results).to include(approved_debit)
        expect(results).not_to include(denied_credit, pending_debit)
      end
    end

    describe '.denied' do
      it 'returns only denied transactions' do
        results = Transaction.denied
        expect(results).to include(denied_credit)
        expect(results).not_to include(approved_debit, pending_debit)
      end
    end

    describe '.credits' do
      it 'returns only credit transactions' do
        results = Transaction.credits
        expect(results).to include(denied_credit)
        expect(results).not_to include(approved_debit, pending_debit)
      end
    end

    describe '.debits' do
      it 'returns only debit transactions' do
        results = Transaction.debits
        expect(results).to include(approved_debit, pending_debit)
        expect(results).not_to include(denied_credit)
      end
    end

    describe '.from_atm' do
      it 'returns only ATM transactions' do
        results = Transaction.from_atm
        expect(results).to include(atm_transaction)
        expect(results).not_to include(teller_transaction)
      end
    end

    describe '.from_teller' do
      it 'returns only teller transactions' do
        results = Transaction.from_teller
        expect(results).to include(teller_transaction)
        expect(results).not_to include(atm_transaction)
      end
    end
  end

  describe 'class methods' do
    describe '.process_debit!' do
      it 'creates and processes a debit transaction from ATM' do
        transaction = Transaction.process_debit!(
          card: card,
          amount: 100.00,
          atm_machine: atm_machine
        )

        expect(transaction).to be_persisted
        expect(transaction.debit?).to be true
        expect(transaction.atm?).to be true
        expect(transaction.amount).to eq(100.00)
      end

      it 'creates and processes a debit transaction from teller' do
        transaction = Transaction.process_debit!(
          card: card,
          amount: 100.00
        )

        expect(transaction).to be_persisted
        expect(transaction.debit?).to be true
        expect(transaction.teller?).to be true
        expect(transaction.atm_machine).to be_nil
      end
    end

    describe '.process_credit!' do
      it 'creates and processes a credit transaction' do
        transaction = Transaction.process_credit!(
          card: card,
          amount: 100.00,
          atm_machine: atm_machine
        )

        expect(transaction).to be_persisted
        expect(transaction.credit?).to be true
        expect(transaction.atm?).to be true
        expect(transaction.amount).to eq(100.00)
      end
    end
  end

  describe 'instance methods' do
    describe '#approve!' do
      let(:pending_debit) {
        t = build(:transaction, :debit, card: card, amount: 100.00, status: 'pending')
        t.skip_auto_processing = true
        t.save!
        t
      }
      let(:pending_credit) {
        t = build(:transaction, :credit, card: card, amount: 100.00, status: 'pending')
        t.skip_auto_processing = true
        t.save!
        t
      }

      it 'approves a debit transaction and updates account balance' do
        initial_balance = account.balance
        result = pending_debit.approve!

        expect(result).to be true
        expect(pending_debit.reload.approved?).to be true
        expect(pending_debit.processed_at).to be_present
        expect(account.reload.balance).to eq(initial_balance - 100.00)
      end

      it 'approves a credit transaction and updates account balance' do
        initial_balance = account.balance
        result = pending_credit.approve!

        expect(result).to be true
        expect(pending_credit.reload.approved?).to be true
        expect(pending_credit.processed_at).to be_present
        expect(account.reload.balance).to eq(initial_balance + 100.00)
      end

      it 'denies transaction if insufficient funds' do
        low_balance_account = create(:account, balance: 50.00)
        low_balance_card = create(:card, account: low_balance_account, card_number: '4532015112830888')

        pending_debit = build(:transaction, :debit, card: low_balance_card, amount: 100.00, status: 'pending')
        pending_debit.skip_auto_processing = true
        pending_debit.save!

        result = pending_debit.approve!

        expect(result).to be false
        expect(pending_debit.reload.denied?).to be true
        expect(low_balance_account.reload.balance).to eq(50.00) # Unchanged
      end

      it 'does not approve already processed transactions' do
        approved_transaction = build(:transaction, :approved, card: card)
        approved_transaction.skip_auto_processing = true
        approved_transaction.save!

        result = approved_transaction.approve!
        expect(result).to be false
      end
    end

    describe '#deny!' do
      let(:pending_transaction) {
        t = build(:transaction, :pending, card: card)
        t.skip_auto_processing = true
        t.save!
        t
      }

      it 'denies a pending transaction' do
        result = pending_transaction.deny!('Suspicious activity')

        expect(result).to be true
        expect(pending_transaction.reload.denied?).to be true
        expect(pending_transaction.processed_at).to be_present
        expect(pending_transaction.description).to include('Suspicious activity')
      end

      it 'does not deny already processed transactions' do
        approved_transaction = build(:transaction, :approved, card: card)
        approved_transaction.skip_auto_processing = true
        approved_transaction.save!

        result = approved_transaction.deny!
        expect(result).to be false
      end
    end

    describe '#cancel!' do
      let(:pending_transaction) {
        t = build(:transaction, :pending, card: card)
        t.skip_auto_processing = true
        t.save!
        t
      }

      it 'cancels a pending transaction' do
        result = pending_transaction.cancel!

        expect(result).to be true
        expect(pending_transaction.reload.cancelled?).to be true
        expect(pending_transaction.processed_at).to be_present
      end

      it 'does not cancel already processed transactions' do
        approved_transaction = build(:transaction, :approved, card: card)
        approved_transaction.skip_auto_processing = true
        approved_transaction.save!

        result = approved_transaction.cancel!
        expect(result).to be false
      end
    end

    describe '#formatted_amount' do
      it 'returns currency formatted amount' do
        transaction.amount = 1234.56
        expect(transaction.formatted_amount).to eq('$1,234.56')
      end
    end

    describe '#transaction_type_display' do
      it 'returns capitalized transaction type' do
        transaction.transaction_type = 'debit'
        expect(transaction.transaction_type_display).to eq('Debit')

        transaction.transaction_type = 'credit'
        expect(transaction.transaction_type_display).to eq('Credit')
      end
    end

    describe '#status_display' do
      it 'returns human-readable status' do
        approved_txn = build(:transaction, status: 'approved')
        denied_txn = build(:transaction, status: 'denied')
        pending_txn = build(:transaction, status: 'pending')
        cancelled_txn = build(:transaction, status: 'cancelled')

        expect(approved_txn.status_display).to eq('Approved')
        expect(denied_txn.status_display).to eq('Denied')
        expect(pending_txn.status_display).to eq('Pending')
        expect(cancelled_txn.status_display).to eq('Cancelled')
      end
    end

    describe '#source_display' do
      it 'returns formatted source information' do
        atm_transaction = build(:transaction, :from_atm, atm_machine: atm_machine)
        expect(atm_transaction.source_display).to eq("ATM #{atm_machine.machine_id}")

        teller_transaction = build(:transaction, :from_teller)
        expect(teller_transaction.source_display).to eq('Teller')
      end
    end
  end

  describe 'business logic integration' do
    it 'automatically denies debit transactions with insufficient funds' do
      low_balance_account = create(:account, balance: 50.00)
      low_balance_card = create(:card, account: low_balance_account, card_number: '4532015112830777')

      transaction = Transaction.create!(
        card: low_balance_card,
        atm_machine: atm_machine,
        amount: 100.00,
        transaction_type: 'debit',
        source: 'atm'
      )

      expect(transaction.reload.denied?).to be true
      expect(low_balance_account.reload.balance).to eq(50.00) # Unchanged
    end

    it 'automatically approves valid transactions' do
      transaction = Transaction.create!(
        card: card,
        atm_machine: atm_machine,
        amount: 100.00,
        transaction_type: 'debit',
        source: 'atm'
      )

      expect(transaction.reload.approved?).to be true
      expect(account.reload.balance).to eq(900.00) # 1000 - 100
    end

    it 'maintains transaction history' do
      # Create multiple transactions
      Transaction.process_debit!(card: card, amount: 100.00, atm_machine: atm_machine)
      Transaction.process_credit!(card: card, amount: 50.00, atm_machine: atm_machine)
      Transaction.process_debit!(card: card, amount: 25.00, atm_machine: atm_machine)

      transactions = account.transactions.recent
      expect(transactions.count).to eq(3)
      expect(transactions.map(&:amount)).to eq([25.00, 50.00, 100.00])

      # Final balance should be 1000 - 100 + 50 - 25 = 925
      expect(account.reload.balance).to eq(925.00)
    end
  end
end
