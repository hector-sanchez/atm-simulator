class Customer < ApplicationRecord
  validates :name, presence: true, length: { maximum: 250 }
  validates :address, presence: true, length: { maximum: 250 }
  validates :city, presence: true
  validates :state, presence: true, length: { is: 2 }
  validates :zipcode, presence: true, format: {
    with: /\A\d{5}(-\d{4})?\z/,
    message: "must be a valid US postal code (e.g., 12345 or 12345-6789)"
  }
end
