class AtmMachine < ApplicationRecord
  # Relationships
  belongs_to :branch, optional: true  # ATM can exist without being at a branch

  # Enums
  enum :status, {
    active: 'active',
    out_of_service: 'out_of_service',
    maintenance: 'maintenance',
    out_of_cash: 'out_of_cash',
    offline: 'offline'
  }

  enum :location_type, {
    branch: 'branch',
    supermarket: 'supermarket',
    gas_station: 'gas_station',
    mall: 'mall',
    airport: 'airport',
    hospital: 'hospital',
    university: 'university',
    standalone: 'standalone',
    other: 'other'
  }

  # Validations
  validates :machine_id, presence: true, uniqueness: true, length: { is: 8 }, format: { with: /\A[A-Z0-9]{8}\z/, message: "must be 8 alphanumeric characters" }
  validates :address, presence: true, length: { maximum: 250 }
  validates :city, presence: true, length: { maximum: 100 }
  validates :state, presence: true, length: { is: 2 }
  validates :zipcode, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid US postal code" }
  validates :country, presence: true, length: { maximum: 50 }
  validates :status, presence: true
  validates :location_type, presence: true
  validates :cash_available, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :out_of_service, -> { where(status: ['out_of_service', 'maintenance', 'offline']) }
  scope :by_location_type, ->(type) { where(location_type: type) }
  scope :with_cash, -> { where('cash_available > 0') }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_city, ->(city) { where(city: city) }

  # Instance methods
  def full_address
    "#{address}, #{city}, #{state} #{zipcode}"
  end

  def operational?
    active? && cash_available > 0
  end

  def location_name
    if branch.present?
      "#{branch.name} Branch"
    else
      "#{location_type.humanize} Location"
    end
  end

  def formatted_cash_available
    "$#{cash_available.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def status_display
    case status
    when 'active'
      'Active'
    when 'out_of_service'
      'Out of Service'
    when 'maintenance'
      'Under Maintenance'
    when 'out_of_cash'
      'Out of Cash'
    when 'offline'
      'Offline'
    else
      status.humanize
    end
  end
end
