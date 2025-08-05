class AuthenticationResult
  def self.success(card)
    new(true, card, nil)
  end

  def self.failure(error)
    new(false, nil, error)
  end

  def initialize(success, card, error)
    @success = success
    @card = card
    @error = error
  end

  attr_reader :card, :error

  def success?
    @success
  end

  def failure?
    !@success
  end

  def error_message
    @error
  end
end
