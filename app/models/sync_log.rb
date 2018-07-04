class SyncLog < ApplicationRecord
  belongs_to :target, polymorphic: true
end
