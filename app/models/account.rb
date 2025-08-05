class Account < ApplicationRecord
  belongs_to :customer
  has_many :cards, dependent: :destroy

  ACCOUNT_TYPES = %w[checking savings].freeze

  validates :account_number, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :account_type, presence: true, inclusion: { in: ACCOUNT_TYPES }

  # Format account number display
  def formatted_account_number
    "****#{account_number.last(4)}"
  end

  # Check if account has sufficient funds
  def sufficient_funds?(amount)
    balance >= amount
  end

  # Debit account (withdraw)
  def debit!(amount)
    raise ArgumentError, "Insufficient funds" unless sufficient_funds?(amount)
    update!(balance: balance - amount)
  end

  # Credit account (deposit)
  def credit!(amount)
    raise ArgumentError, "Amount must be positive" unless amount > 0
    update!(balance: balance + amount)
  end
end
