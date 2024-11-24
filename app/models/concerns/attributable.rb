module Attributable
  extend ActiveSupport::Concern

  included do
    has_many :custom_attributes, as: :attributable, dependent: :destroy
  end

  def set_custom_attribute(key:, value:)
    custom_attribute = custom_attributes.find_or_initialize_by(key:)
    custom_attribute.value = value
    return custom_attribute unless custom_attribute.valid?

    custom_attribute.save!
  end

  def get_custom_attribute(key:)
    return nil if key.blank?

    custom_attributes.find_by(key:).try(:value)
  end

  class_methods do
    def create_custom_field(key:)
      associated_model = self.name.underscore
      custom_field = CustomField.find_or_initialize_by(associated_model:, name: key)

      if custom_field.new_record? && custom_field.valid?
        return custom_field.save! && custom_field
      end

      custom_field
    end
  end
end
