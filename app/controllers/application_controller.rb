class ApplicationController < ActionController::Base
  # Protect from forgery attacks in forms
  protect_from_forgery with: :exception

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
