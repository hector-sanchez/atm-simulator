class ApplicationController < ActionController::Base
  # Protect from forgery attacks in forms
  protect_from_forgery with: :exception
end
