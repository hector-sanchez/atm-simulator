class AtmController < ApplicationController
  layout 'atm'
  before_action :require_authentication

  def index
    @current_card = Card.includes(account: :customer).find(session[:card_id])
    @current_account = @current_card.account
    @current_customer = @current_account.customer

    # Create presenters for clean view logic
    @card_presenter = CardPresenter.new(@current_card)
    @account_presenter = AccountPresenter.new(@current_account)
  end

  private

  def require_authentication
    unless session[:card_id]
      redirect_to login_path, alert: "Please authenticate your card to continue."
    end
  end
end
