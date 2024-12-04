class CustomField < ApplicationRecord
  validates :name, :associated_model, presence: true
  validates_uniqueness_of :name, scope: :associated_model

  normalizes :name, :associated_model, with: ->(value) { value.strip.downcase }

  scope :by_model, ->(associated_model:) { where(associated_model:).pluck(:name) }
end
