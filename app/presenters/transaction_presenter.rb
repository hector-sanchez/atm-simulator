class TransactionPresenter
  def initialize(transaction)
    @transaction = transaction
  end

  # Delegate basic attributes to the transaction
  delegate :id, :amount, :transaction_type, :source, :status, :created_at, :description, :reference_number, :transaction_type_display, to: :@transaction

  # Access to the underlying transaction object
  def transaction
    @transaction
  end

  def amount_positive?
    amount.positive?
  end

  # Date formatting methods
  def formatted_date
    @transaction.created_at.strftime("%m/%d/%Y")
  end

  def formatted_time
    @transaction.created_at.strftime("%I:%M %p")
  end

  def formatted_datetime
    @transaction.created_at.strftime("%m/%d/%Y at %I:%M %p")
  end

  # Type display methods
  def type_icon
    @transaction.transaction_type == 'credit' ? '💰' : '💳'
  end

  def type_display
    @transaction.transaction_type.humanize
  end

  def type_css_class
    @transaction.transaction_type
  end

  def source_display
    @transaction.source.humanize
  end

  # Amount display methods
  def formatted_amount
    ActionController::Base.helpers.number_with_precision(@transaction.amount, precision: 2)
  end

  def amount_with_sign
    sign = @transaction.transaction_type == 'credit' ? '+' : '-'
    "#{sign}$#{formatted_amount}"
  end

  def amount_css_class
    @transaction.transaction_type
  end

  # Location display methods
  def location_name
    if @transaction.atm_machine
      @transaction.atm_machine.location_name
    else
      "Teller Transaction"
    end
  end

  def location_address
    if @transaction.atm_machine
      "#{@transaction.atm_machine.city}, #{@transaction.atm_machine.state}"
    else
      "In-Branch Service"
    end
  end

  def has_atm_location?
    @transaction.atm_machine.present?
  end

  def atm_machine_id
    @transaction.atm_machine&.machine_id
  end

  # Status display methods
  def status_icon
    @transaction.status == 'approved' ? '✅' : '❌'
  end

  def status_display
    @transaction.status.humanize
  end

  def status_css_class
    @transaction.status
  end

  # CSS classes for styling
  def row_css_class
    "transaction-row #{@transaction.transaction_type}"
  end

  def type_badge_css_class
    "type-badge #{@transaction.transaction_type}"
  end

  def status_badge_css_class
    "status-badge #{@transaction.status}"
  end

  # Convenience methods
  def approved?
    @transaction.status == 'approved'
  end

  def denied?
    @transaction.status == 'denied'
  end

  def credit?
    @transaction.transaction_type == 'credit'
  end

  def debit?
    @transaction.transaction_type == 'debit'
  end

  def from_atm?
    @transaction.source == 'atm'
  end

  def from_teller?
    @transaction.source == 'teller'
  end
end
