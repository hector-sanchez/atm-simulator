class Transaction < ApplicationRecord
  belongs_to :card
  belongs_to :atm_machine, optional: true # Optional for teller transactions

  # Delegate account access through card
  delegate :account, to: :card

  # Constants
  TRANSACTION_TYPES = %w[credit debit].freeze
  SOURCES = %w[atm teller].freeze
  STATUSES = %w[approved denied pending cancelled].freeze

  # Enums
  enum :transaction_type, { credit: 'credit', debit: 'debit' }
  enum :source, { atm: 'atm', teller: 'teller' }
  enum :status, { approved: 'approved', denied: 'denied', pending: 'pending', cancelled: 'cancelled' }

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true
  validates :source, presence: true
  validates :status, presence: true
  validates :reference_number, presence: true, uniqueness: true,
            format: { with: /\A[A-Z0-9]{10,20}\z/, message: "must be 10-20 alphanumeric characters" }

  # Custom validations
  validate :atm_machine_required_for_atm_transactions

  # Callbacks
  before_validation :generate_reference_number, on: :create, if: -> { reference_number.blank? }
  before_validation :set_default_status, on: :create, if: -> { status.blank? }
  after_create :process_transaction, if: -> { pending? && !@skip_auto_processing }
  after_update :update_account_balance, if: -> { saved_change_to_status? && approved? }

  # Allow skipping auto-processing for tests
  attr_accessor :skip_auto_processing

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :approved, -> { where(status: 'approved') }
  scope :denied, -> { where(status: 'denied') }
  scope :for_account, ->(account_id) { joins(:card).where(cards: { account_id: account_id }) }
  scope :for_card, ->(card_id) { where(card_id: card_id) }
  scope :from_atm, -> { where(source: 'atm') }
  scope :from_teller, -> { where(source: 'teller') }
  scope :credits, -> { where(transaction_type: 'credit') }
  scope :debits, -> { where(transaction_type: 'debit') }

  # Class methods for creating and processing transactions
  def self.process_debit!(card:, amount:, atm_machine: nil, reference_number: nil)
    create!(
      card: card,
      atm_machine: atm_machine,
      amount: amount,
      transaction_type: 'debit',
      source: atm_machine ? 'atm' : 'teller',
      reference_number: reference_number
    )
  end

  def self.process_credit!(card:, amount:, atm_machine: nil, reference_number: nil)
    create!(
      card: card,
      atm_machine: atm_machine,
      amount: amount,
      transaction_type: 'credit',
      source: atm_machine ? 'atm' : 'teller',
      reference_number: reference_number
    )
  end

  # Instance methods
  def approve!
    return false unless pending?

    # For debit transactions, check funds before approving
    if debit? && account.insufficient_funds?(amount)
      update!(status: 'denied', processed_at: Time.current)
      return false
    end

    # Approve the transaction - balance update handled by callback
    update!(
      status: 'approved',
      processed_at: Time.current
    )

    true
  rescue => e
    update!(status: 'denied', processed_at: Time.current)
    false
  end

  def deny!(reason = nil)
    return false unless pending?

    description_with_reason = if reason.present?
      [description, reason].compact.join('. ')
    else
      description
    end

    update!(
      status: 'denied',
      processed_at: Time.current,
      description: description_with_reason
    )

    true
  end

  def cancel!
    return false unless pending?

    update!(
      status: 'cancelled',
      processed_at: Time.current
    )

    true
  end

  def formatted_amount
    ActionController::Base.helpers.number_to_currency(amount)
  end

  def transaction_type_display
    transaction_type.capitalize
  end

  def status_display
    case status
    when 'approved'
      'Approved'
    when 'denied'
      'Denied'
    when 'pending'
      'Pending'
    when 'cancelled'
      'Cancelled'
    end
  end

  def source_display
    case source
    when 'atm'
      atm_machine ? "ATM #{atm_machine.machine_id}" : 'ATM'
    when 'teller'
      'Teller'
    end
  end

  private

  def generate_reference_number
    # Generate unique alphanumeric reference: TXN + timestamp + random
    loop do
      ref = "TXN#{Time.current.strftime('%Y%m%d')}#{SecureRandom.alphanumeric(6).upcase}"
      break self.reference_number = ref unless Transaction.exists?(reference_number: ref)
    end
  end

  def set_default_status
    self.status = 'pending'
  end

  def process_transaction
    # Auto-approve or deny based on business rules
    if debit? && account.insufficient_funds?(amount)
      deny!("Insufficient funds")
    else
      approve!
    end
  end

  def atm_machine_required_for_atm_transactions
    if atm? && atm_machine.blank?
      errors.add(:atm_machine, "is required for ATM transactions")
    end
  end

  # Callback to update account balance when transaction is approved
  def update_account_balance
    return unless approved?

    amnt = debit? ? -(amount) : amount
    account.update_balance!(amnt)
  end
end
