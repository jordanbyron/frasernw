module Referrable
  extend ActiveSupport::Concern

  included do
    has_many :referral_forms, :as => :referrable, :dependent => :destroy
    accepts_nested_attributes_for :referral_forms, :allow_destroy => true
  end

end
