module Referrable
  extend ActiveSupport::Concern

  included do
    has_many :referral_forms, as: :referrable, dependent: :destroy
    accepts_nested_attributes_for :referral_forms, allow_destroy: true
  end

  REFERRAL_ICONS = {
    green_check: "icon-ok icon-green",
    orange_check: "icon-ok icon-orange",
    red_x:  "icon-remove icon-red",
    blue_arrow: "icon-signout icon-blue",
    orange_warning: "icon-warning-sign icon-orange",
    question_mark: "icon-question-sign",
  }

  REFERRAL_TOOLTIPS = {
    green_check: "Accepting new referrals",
    orange_check: "Accepting new referrals limited by geography or number of patients",
    red_x: "Not accepting new referrals",
    blue_arrow: ("Only works out of, and possibly accepts referrals through hospitals " +
    "and/or clinics"),
    orange_warning: "Unavailable soon.",
    question_mark: "Unknown if accepting new patients (didn't respond)",
  }

  def referral_icon_classes
    REFERRAL_ICONS[referral_icon_key]
  end

  def referral_icon_key
    raise "define me!"
  end

end
