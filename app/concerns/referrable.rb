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

  APPOINTMENT_WAIT_TIMES = {
    1 => "Within one week",
    2 => "1-2 weeks",
    3 => "2-4 weeks",
    4 => "1-2 months",
    5 => "2-4 months",
    6 => "4-6 months",
    7 => "6-9 months",
    8 => "9-12 months",
    9 => "12-18 months",
    10 => "18-24 months",
    11 => "2-2.5 years",
    12 => "2.5-3 years",
    13 => ">3 years"
  }

  BOOKING_WAIT_TIMES = {
    1 => "Book by phone when office calls for referral",
    2 => "Within one week",
    3 => "1-2 weeks",
    4 => "2-4 weeks",
    5 => "1-2 months",
    6 => "2-4 months",
    7 => "4-6 months",
    8 => "6-9 months",
    9 => "9-12 months",
    10 => "12-18 months",
    11 => "18-24 months",
    12 => "2-2.5 years",
    13 => "2.5-3 years",
    14 => ">3 years"
  }

  def referral_icon_classes
    REFERRAL_ICONS[referral_icon_key]
  end

  def referral_icon_key
    raise "define me!"
  end

end
