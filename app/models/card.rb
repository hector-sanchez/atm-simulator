require 'bcrypt'

class Card < ApplicationRecord
  belongs_to :account

  # Rails 7+ built-in encryption for sensitive data
  # encrypts :card_number  # Temporarily disabled for testing

  # Constants
  CARD_TYPES = %w[visa mastercard discover].freeze
  STATUSES = %w[active blocked expired suspended].freeze

  # Virtual attributes for plain text values
  attr_accessor :pin, :cvc

  # Validations
  validates :card_token, presence: true, uniqueness: true
  validates :card_number, presence: true, uniqueness: true
  validates :cardholder_name, presence: true, length: { maximum: 250 }, allow_blank: false
  validates :last_four_digits, presence: true, length: { is: 4 },
            format: { with: /\A\d{4}\z/, message: "must be 4 digits" }
  validates :pin_digest, presence: true
  validates :cvc_digest, presence: true
  validates :expiration_date, presence: true
  validates :card_type, presence: true, inclusion: { in: CARD_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # Custom validations
  validate :expiration_date_in_future, on: :create, unless: :skip_expiration_validation

  attr_accessor :skip_expiration_validation
  validate :card_number_format
  validate :pin_format, if: -> { pin.present? }
  validate :cvc_format, if: -> { cvc.present? }

  # Callbacks
  before_validation :generate_card_token, on: :create
  before_validation :extract_last_four_digits
  before_validation :hash_pin, if: -> { pin.present? && pin_digest.blank? }
  before_validation :hash_cvc, if: -> { cvc.present? && cvc_digest.blank? }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :expired, -> { where('expiration_date < ?', Date.current) }
  scope :valid_cards, -> { active.where('expiration_date >= ?', Date.current) }

  # Instance methods
  def active?
    status == 'active'
  end

  def expired?
    expiration_date < Date.current
  end

  def blocked?
    status == 'blocked'
  end

  def valid_for_use?
    active? && !expired?
  end

  def authenticate_pin(pin_attempt)
    BCrypt::Password.new(pin_digest) == pin_attempt
  end

  def authenticate_cvc(cvc_attempt)
    BCrypt::Password.new(cvc_digest) == cvc_attempt
  end

  # Generate expiration date (2 years from now)
  def self.default_expiration_date
    2.years.from_now.to_date
  end

  # Clean authentication method with proper error handling
  def self.authenticate_with_pin(card_number, pin)
    # Clean and validate inputs
    clean_card_number = card_number&.to_s&.gsub(/\D/, '')
    clean_pin = pin&.to_s

    return AuthenticationResult.failure("Card number is required") if clean_card_number.blank?
    return AuthenticationResult.failure("Invalid card number format") unless clean_card_number.length == 16
    return AuthenticationResult.failure("PIN is required") if clean_pin.blank?
    return AuthenticationResult.failure("Invalid PIN format") unless clean_pin.match?(/\A\d{4}\z/)

    # Find card
    card = find_by(card_number: clean_card_number)
    return AuthenticationResult.failure("Invalid card number") unless card

    # Validate card status
    return AuthenticationResult.failure("Card is blocked. Please contact your bank.") if card.blocked?
    return AuthenticationResult.failure("Card is suspended. Please contact your bank.") if card.status == 'suspended'
    return AuthenticationResult.failure("Card has expired") if card.expired?
    return AuthenticationResult.failure("Card is not active") unless card.active?

    # Validate PIN
    return AuthenticationResult.failure("Invalid PIN") unless card.authenticate_pin(clean_pin)

    # Success!
    AuthenticationResult.success(card)
  end

  private

  def generate_card_token
    self.card_token ||= loop do
      token = SecureRandom.hex(16)
      break token unless Card.exists?(card_token: token)
    end
  end

  def extract_last_four_digits
    if card_number.present? && card_number.length >= 4
      self.last_four_digits = card_number.last(4)
    end
  end

  def hash_pin
    self.pin_digest = BCrypt::Password.create(pin)
  end

  def hash_cvc
    self.cvc_digest = BCrypt::Password.create(cvc)
  end

  def expiration_date_in_future
    if expiration_date.present? && expiration_date <= Date.current
      errors.add(:expiration_date, "must be in the future")
    end
  end

  def card_number_format
    if card_number.present?
      # Remove any spaces or dashes
      clean_number = card_number.gsub(/\D/, '')

      # Check if it's 16 digits
      unless clean_number.length == 16 && clean_number.match?(/\A\d{16}\z/)
        errors.add(:card_number, "must be exactly 16 digits")
      end

      # Update with clean number
      self.card_number = clean_number
    end
  end

  def pin_format
    unless pin.match?(/\A\d{4}\z/)
      errors.add(:pin, "must be exactly 4 digits")
    end
  end

  def cvc_format
    unless cvc.match?(/\A\d{3}\z/)
      errors.add(:cvc, "must be exactly 3 digits")
    end
  end
end
