module OffersTeleservices
  extend ActiveSupport::Concern

  def offered_teleservices
    teleservices.sort_by(&:service_type_key).select(&:offered?)
  end

  included do
    attr_accessible :teleservices_attributes

    has_many :teleservices, as: :teleservice_provider, dependent: :destroy
    accepts_nested_attributes_for :teleservices
  end
end
