class Branch < ApplicationRecord
  # Relationships
  has_many :atm_machines, dependent: :nullify

  # Validations
  validates :name, presence: true, length: { maximum: 250 }
  validates :address, presence: true, length: { maximum: 250 }
  validates :city, presence: true, length: { maximum: 100 }
  validates :state, presence: true, length: { is: 2 }
  validates :zipcode, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid US postal code" }
  validates :country, presence: true, length: { maximum: 50 }
  validates :phone, presence: true, format: { with: /\A\d{10}\z/, message: "must be a 10-digit phone number" }
  validates :branch_code, presence: true, uniqueness: true, length: { is: 4 }, format: { with: /\A[A-Z0-9]{4}\z/, message: "must be 4 alphanumeric characters" }
  validates :operating_hours, presence: true

  # Scopes
  scope :by_state, ->(state) { where(state: state) }
  scope :by_city, ->(city) { where(city: city) }

  # Instance methods
  def full_address
    "#{address}, #{city}, #{state} #{zipcode}"
  end

  def formatted_phone
    phone.gsub(/(\d{3})(\d{3})(\d{4})/, '(\1) \2-\3')
  end

  def atm_count
    atm_machines.count
  end
end
