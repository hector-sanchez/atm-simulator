class SessionsController < ApplicationController
  layout 'atm_kiosk'

  # GET /login
  def new
    # Render the card authentication form
  end

  # POST /login
  def create
    @card_number = params[:card_number]&.strip
    @pin = params[:pin]&.strip

    if @card_number.blank? || @pin.blank?
      @error_message = "Please enter both card number and PIN"
      render :new, status: :unprocessable_entity
      return
    end

    result = Card.authenticate_with_pin(@card_number, @pin)

    if result.success?
      session[:card_id] = result.card.id
      session[:account_id] = result.card.account.id

      # Redirect to ATM main interface (to be created)
      redirect_to atm_path, notice: "Welcome! Please select a transaction."
    else
      @error_message = result.error
      @card_number = @card_number # Preserve card number for user convenience
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    session.delete(:card_id)
    session.delete(:account_id)
    session.delete(:atm_machine_id)
    session.delete(:user_location)
    session.delete(:selection_reason)
    redirect_to root_path, notice: "You have been logged out successfully."
  end

  private

  def require_authentication
    # This will be used by other controllers
    unless session[:card_id]
      redirect_to login_path, alert: "Please log in to continue."
    end
  end
end
