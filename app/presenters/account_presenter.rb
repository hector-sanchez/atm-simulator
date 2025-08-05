class AccountPresenter
  def initialize(account)
    @account = account
  end

  # Delegate basic attributes to the account
  delegate :account_number, :account_type, :balance, :customer, to: :@account

  # Presentation methods
  def formatted_account_number
    return "****#{account_number.last(4)}" if account_number.present?
    "****0000"
  end

  def formatted_balance
    ActionController::Base.helpers.number_to_currency(@account.balance)
  end

  def account_type_display
    @account.account_type.capitalize
  end

  def account_type_titleized
    @account.account_type.titleize
  end
end
