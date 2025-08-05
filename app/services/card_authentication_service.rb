class CardAuthenticationService
  # For backward compatibility, delegate to the Card model
  # This service now just provides a consistent interface
  def self.authenticate(card_number, pin)
    Card.authenticate_with_pin(card_number, pin)
  end

  # Keep the AuthenticationResult for backward compatibility
  # But now it's just an alias to the model's result
  AuthenticationResult = ::AuthenticationResult
end
