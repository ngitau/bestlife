class CustomAttribute < ApplicationRecord
  belongs_to :attributable, polymorphic: true

  validates :key, :value, presence: true
  validates :key, uniqueness: { scope: %i[attributable_type attributable_id] }

  normalizes :key, with: ->(value) { value.strip.downcase }
end
