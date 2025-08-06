class AtmLocator
  # Simulated user locations - in real app this could come from IP geolocation, GPS, etc.
  USER_LOCATIONS = [
    { name: "Downtown Area", city: "Anytown", state: "CA", zipcode: "12345" },
    { name: "Westside Shopping", city: "Anytown", state: "CA", zipcode: "12346" },
    { name: "University District", city: "Anytown", state: "CA", zipcode: "12348" },
    { name: "Shopping Center", city: "Anytown", state: "CA", zipcode: "12347" },
    { name: "Airport Terminal", city: "Anytown", state: "CA", zipcode: "12349" }
  ].freeze

  def self.find_nearest_atm
    # Step 1: Simulate user's current location
    user_location = USER_LOCATIONS.sample

    # Step 2: Find operational ATMs near that location (same city for simplicity)
    nearby_atms = AtmMachine.active_with_cash_near_city(user_location[:city])

    # Step 3: If no nearby operational ATMs, fall back to any operational ATM
    if nearby_atms.empty?
      nearby_atms = AtmMachine.active.with_cash
    end

    # Step 4: Randomly select from available ATMs
    selected_atm = nearby_atms.sample

    {
      atm_machine: selected_atm,
      user_location: user_location,
      selection_reason: determine_selection_reason(selected_atm, user_location)
    }
  end

  def self.find_atm_by_location_type(location_preference)
    case location_preference.downcase
    when 'branch'
      AtmMachine.active_with_cash_at_branch.sample
    when 'supermarket', 'grocery'
      AtmMachine.active_with_cash_at_market_or_grocery.sample
    when 'university', 'school'
      AtmMachine.active_with_cash_at_university.sample
    when 'airport'
      AtmMachine.active_with_cash_at_airport.sample
    else
      find_nearest_atm[:atm_machine]
    end
  end

  private

  def self.determine_selection_reason(atm, user_location)
    if atm.branch.present?
      "Nearest branch ATM in #{user_location[:name]}"
    else
      "Convenient #{atm.location_type.humanize.downcase} ATM in #{user_location[:name]}"
    end
  end
end
