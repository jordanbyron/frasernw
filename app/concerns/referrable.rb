module Referrable
  extend ActiveSupport::Concern

  included do
    has_many :referral_forms, as: :referrable, dependent: :destroy
    accepts_nested_attributes_for :referral_forms, allow_destroy: true
  end

  REFERRAL_ICONS = {
    none: "",
    question_mark: "icon-question-sign",
    blue_arrow: "icon-signout icon-blue",
    orange_check: "icon-ok icon-orange",
    orange_warning: "icon-warning-sign icon-orange",
    green_check: "icon-ok icon-green",
    red_x:  "icon-remove icon-red"
  }

  REFERRAL_TOOLTIPS = {
    none: "",
    question_mark: ("Unknown if accepting new patients (didn't respond)."),
    blue_arrow: "Only accepts referrals through hospitals and/or clinics.",
    orange_check: "Accepting new referrals limited by geography or number of patients",
    orange_warning: "Unavailable soon.",
    green_check: "Accepting new referrals",
    red_x: "Not accepting new referrals"
  }

  def referral_icon_classes
    REFERRAL_ICONS[referral_icon_key]
  end

  def referral_icon_key
    raise "define me!"
  end

end
