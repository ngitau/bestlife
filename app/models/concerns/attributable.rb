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
end
