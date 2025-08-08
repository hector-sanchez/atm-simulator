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

  def create
    @current_card = Card.includes(account: :customer).find(session[:card_id])
    @current_account = @current_card.account
    @current_atm = AtmMachine.find(session[:atm_machine_id])

    Rails.logger.info "Transaction create called with params: #{transaction_params.inspect}"

    amount = transaction_params[:amount].to_f
    transaction_type = transaction_params[:transaction_type]

    Rails.logger.info "Parsed amount: #{amount}, Transaction type: #{transaction_type}, Account balance: #{@current_account.balance}"

    # Validate transaction amount
    if amount <= 0
      Rails.logger.warn "Invalid amount: #{amount}"
      return render_transaction_response(false, "Please enter a valid #{transaction_type == 'debit' ? 'withdrawal' : 'deposit'} amount.")
    end

    if transaction_type == 'debit' && amount > @current_account.balance
      Rails.logger.warn "Insufficient funds: #{amount} > #{@current_account.balance}"
      return render_transaction_response(false, "Insufficient funds. Your current balance is #{AccountPresenter.new(@current_account).formatted_balance}.")
    end

    if transaction_type == 'credit' && amount > 10000
      Rails.logger.warn "Deposit amount too large: #{amount}"
      return render_transaction_response(false, "Maximum deposit amount is $10,000.00.")
    end

    # Create the transaction
    begin
      ActiveRecord::Base.transaction do
        old_balance = @current_account.balance

        # For debit transactions, make amount negative
        transaction_amount = transaction_type == 'debit' ? -(amount) : amount

        # Update account balance
        @current_account.update_balance!(transaction_amount)

        # Create transaction record with the original positive amount
        transaction = Transaction.create!(
          card: @current_card,
          atm_machine: @current_atm,
          transaction_type: transaction_type,
          amount: amount, # Always store positive amount
          status: 'approved',
          source: 'atm',
          reference_number: generate_reference_number
        )

        # Log the successful transaction
        Rails.logger.info "#{transaction_type.capitalize} successful: Card #{@current_card.card_number}, Amount: $#{amount}, Old Balance: $#{old_balance}, New Balance: $#{@current_account.balance}"

        action_text = transaction_type == 'debit' ? 'withdrew' : 'deposited'
        success_message = "#{transaction_type.capitalize} successful! You #{action_text} #{ActionController::Base.helpers.number_to_currency(amount)}. Your new balance is #{AccountPresenter.new(@current_account.reload).formatted_balance}."

        render_transaction_response(true, success_message)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "#{transaction_type.capitalize} failed: #{e.message}"
      Rails.logger.error "Validation errors: #{e.record.errors.full_messages.join(', ')}" if e.record.errors.any?
      render_transaction_response(false, "Transaction failed: #{e.record.errors.full_messages.join(', ')}. Please try again.")
    rescue StandardError => e
      Rails.logger.error "Unexpected error during #{transaction_type}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render_transaction_response(false, "An unexpected error occurred. Please try again.")
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:amount, :transaction_type)
  end

  def render_transaction_response(success, message)
    respond_to do |format|
      format.json do
        if success
          render json: { success: true, message: message, redirect_url: atm_path }
        else
          render json: { success: false, error: message }
        end
      end
      format.html do
        if success
          redirect_to atm_path, notice: message
        else
          redirect_to atm_path, alert: message
        end
      end
    end
  end

  private

  def generate_reference_number
    # Generate a unique reference number for the transaction
    "ATM#{Time.current.strftime('%Y%m%d')}#{SecureRandom.hex(4).upcase}"
  end

  def require_authentication
    unless session[:card_id]
      redirect_to login_path, alert: "Please authenticate your card to continue."
    end
  end
end
