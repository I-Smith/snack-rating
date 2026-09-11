class Snack < ApplicationRecord
  scope :search, ->(query) {
    where("name LIKE ? OR brand LIKE ? OR country_of_origin LIKE ? OR notes LIKE ?",
          "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
  }

  validates :name, presence: true
  validates :brand, presence: true
  validates :isaac_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validates :kristina_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
end
