module Attributable
  extend ActiveSupport::Concern

  included do
    has_many :custom_attributes, as: :attributable, dependent: :destroy
  end

  def set_custom_attribute(key:, value:)
    custom_attribute = custom_attributes.find_or_initialize_by(key:)
    validate_key!(custom_attribute:, key:)
    return custom_attribute if custom_attribute.errors.any?

    custom_attribute.value = value
    custom_attribute.save!
  end

  def get_custom_attribute(key:)
    return nil if key.blank?

    custom_attributes.find_by(key:).try(:value)
  end

  private

  def custom_fields
    associated_model = self.class.name.underscore
    CustomField.by_model(associated_model:)
  end

  def validate_key!(custom_attribute:, key:)
    if key.blank?
      custom_attribute.errors.add(:key, :blank)
    elsif custom_fields.blank?
      custom_attribute.errors.add(:key, :custom_fields_not_set)
    elsif !key.in?(custom_fields)
      custom_attribute.errors.add(:key, :invalid_key)
    end
  end
end