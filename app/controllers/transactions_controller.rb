class TransactionsController < ApplicationController
  layout 'atm'
  before_action :require_authentication
  before_action :assign_atm_location

  def index
    @current_card = Card.includes(account: :customer).find(session[:card_id])
    @current_account = @current_card.account
    @current_customer = @current_account.customer

    # Get all transactions for the account (through all cards)
    transactions = Transaction.includes(:card, :atm_machine)
                              .joins(:card)
                              .where(cards: { account_id: @current_account.id })
                              .order(created_at: :desc)
                              .page(params[:page])
                              .per(10) # 10 transactions per page

    # Create presenters for clean view logic
    @transaction_presenters = transactions.map { |transaction| TransactionPresenter.new(transaction) }
    @transactions = transactions # Keep for pagination
    @card_presenter = CardPresenter.new(@current_card)
    @account_presenter = AccountPresenter.new(@current_account)
  end

  private

  def require_authentication
    unless session[:card_id]
      redirect_to login_path, alert: "Please authenticate your card to continue."
    end
  end

  def assign_atm_location
    # Only assign ATM once per session, but handle stale session data
    unless session[:atm_machine_id] && AtmMachine.exists?(session[:atm_machine_id])
      location_data = AtmLocator.find_nearest_atm

      session[:atm_machine_id] = location_data[:atm_machine].id
      session[:user_location] = location_data[:user_location]
      session[:selection_reason] = location_data[:selection_reason]
    end

    @current_atm = AtmMachine.find(session[:atm_machine_id])
    @user_location = session[:user_location]
    @selection_reason = session[:selection_reason]
  rescue ActiveRecord::RecordNotFound
    # Handle case where stored ATM ID is invalid (e.g., after database reset)
    location_data = AtmLocator.find_nearest_atm

    session[:atm_machine_id] = location_data[:atm_machine].id
    session[:user_location] = location_data[:user_location]
    session[:selection_reason] = location_data[:selection_reason]

    @current_atm = location_data[:atm_machine]
    @user_location = location_data[:user_location]
    @selection_reason = location_data[:selection_reason]
  end
end
