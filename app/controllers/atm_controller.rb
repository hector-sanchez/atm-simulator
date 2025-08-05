class AtmController < ApplicationController
  layout 'atm'
  before_action :require_authentication
  before_action :assign_atm_location, only: [:index]

  def index
    @current_card = Card.includes(account: :customer).find(session[:card_id])
    @current_account = @current_card.account
    @current_customer = @current_account.customer

    # Fetch all cards for the current account
    @all_cards = @current_account.cards.includes(:account)

    # Create presenters for clean view logic
    @card_presenter = CardPresenter.new(@current_card)
    @account_presenter = AccountPresenter.new(@current_account)
    @card_presenters = @all_cards.map { |card| CardPresenter.new(card) }
  end

  private

  def require_authentication
    unless session[:card_id]
      redirect_to login_path, alert: "Please authenticate your card to continue."
    end
  end

  def assign_atm_location
    # Only assign ATM once per session
    unless session[:atm_machine_id]
      location_data = SessionLocationService.assign_atm_for_session

      session[:atm_machine_id] = location_data[:atm_machine].id
      session[:user_location] = location_data[:user_location]
      session[:selection_reason] = location_data[:selection_reason]
    end

    @current_atm = AtmMachine.find(session[:atm_machine_id])
    @user_location = session[:user_location]
    @selection_reason = session[:selection_reason]
  end
end
