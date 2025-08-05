class SessionLocationService
  # Simulated user locations - in real app this could come from IP geolocation, GPS, etc.
  USER_LOCATIONS = [
    { name: "Downtown Area", city: "Anytown", state: "CA", zipcode: "12345" },
    { name: "Westside Shopping", city: "Anytown", state: "CA", zipcode: "12346" },
    { name: "University District", city: "Anytown", state: "CA", zipcode: "12348" },
    { name: "Shopping Center", city: "Anytown", state: "CA", zipcode: "12347" },
    { name: "Airport Terminal", city: "Anytown", state: "CA", zipcode: "12349" }
  ].freeze

  def self.assign_atm_for_session
    # Step 1: Simulate user's current location
    user_location = USER_LOCATIONS.sample

    # Step 2: Find operational ATMs near that location (same city for simplicity)
    nearby_atms = AtmMachine.joins("LEFT JOIN branches ON atm_machines.branch_id = branches.id")
                           .where(
                             "(atm_machines.city = ? OR branches.city = ?) AND atm_machines.status = ?",
                             user_location[:city], user_location[:city], 'active'
                           )
                           .where('atm_machines.cash_available > 0')

    # Step 3: If no nearby operational ATMs, fall back to any operational ATM
    if nearby_atms.empty?
      nearby_atms = AtmMachine.where(status: 'active').where('cash_available > 0')
    end

    # Step 4: Randomly select from available ATMs
    selected_atm = nearby_atms.sample

    {
      atm_machine: selected_atm,
      user_location: user_location,
      selection_reason: determine_selection_reason(selected_atm, user_location)
    }
  end

  def self.assign_specific_atm_by_location(location_preference)
    case location_preference.downcase
    when 'branch'
      AtmMachine.joins(:branch).where(status: 'active').where('cash_available > 0').sample
    when 'supermarket', 'grocery'
      AtmMachine.where(location_type: 'supermarket', status: 'active').where('cash_available > 0').sample
    when 'university', 'school'
      AtmMachine.where(location_type: 'university', status: 'active').where('cash_available > 0').sample
    when 'airport'
      AtmMachine.where(location_type: 'airport', status: 'active').where('cash_available > 0').sample
    else
      assign_atm_for_session[:atm_machine]
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
