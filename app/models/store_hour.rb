class StoreHour < ApplicationRecord
  belongs_to :store

  acts_as_paranoid
end
