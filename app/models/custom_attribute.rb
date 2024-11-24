class CustomAttribute < ApplicationRecord
  belongs_to :attributable, polymorphic: true

  validates :key, :value, presence: true
  validates :key, uniqueness: { scope: %i[attributable_type attributable_id] }
  validate :valid_key?, if: -> { attributable.present? }

  normalizes :key, with: ->(value) { value.strip.downcase }

  private

  def custom_fields
    associated_model = attributable_type.underscore
    CustomField.by_model(associated_model:)
  end

  def valid_key?
    if key.blank?
      errors.add(:key, :blank)
    elsif custom_fields.blank?
      errors.add(:key, :custom_fields_not_set)
    elsif !key.in?(custom_fields)
      errors.add(:key, :invalid_key)
    end
  end
end
