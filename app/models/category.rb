class Category < ApplicationRecord
  has_and_belongs_to_many :products

  scope :level_1, -> { where(level: 1) }
  scope :level_2, -> { where(level: 2) }
end
