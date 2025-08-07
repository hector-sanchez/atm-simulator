class CardPresenter
  def initialize(card)
    @card = card
  end

  # Delegate basic attributes to the card
  delegate :account, :customer, :card_type, :status, :expiration_date, :created_at, to: :@card

  # Access to the underlying card object
  def card
    @card
  end

  # Presentation methods that were in the model/view
  def formatted_display
    return "****#{last_four_digits}" if @card.respond_to?(:last_four_digits)
    # Fallback if last_four_digits is not available
    card_number = @card.card_number
    return "****#{card_number.last(4)}" if card_number.present?
    "****0000"
  end

  def formatted_expiration
    @card.expiration_date.strftime("%m/%y")
  end

  def card_type_display
    @card.card_type.upcase
  end

  def status_display
    @card.status.titleize
  end

  def status_css_class
    case @card.status.downcase
    when 'active'
      'status-active'
    when 'blocked', 'suspended'
      'status-blocked'
    when 'expired'
      'status-expired'
    else
      'status-unknown'
    end
  end

  # Customer-related presentation methods
  def cardholder_name
    @card.cardholder_name&.upcase || customer.name.upcase
  end

  def customer_first_name
    cardholder_first_name = @card.cardholder_name&.split&.first
    cardholder_first_name || customer.name.split.first
  end

  def customer
    @card.account.customer
  end

  def last_four_digits
    @card.last_four_digits
  end
end
