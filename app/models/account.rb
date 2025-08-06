class Account < ApplicationRecord
  belongs_to :customer
  has_many :cards, dependent: :destroy
  has_many :transactions, through: :cards

  ACCOUNT_TYPES = %w[checking savings].freeze

  validates :account_number, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :account_type, presence: true, inclusion: { in: ACCOUNT_TYPES }

  # Check if account has sufficient funds
  def sufficient_funds?(amount)
    balance >= amount
  end

  def insufficient_funds?(amount)
    !sufficient_funds?(amount)
  end

  def update_balance!(amount)
    # for debit transactions amount will be negative
    update!(balance: balance + amount)
  end
end
