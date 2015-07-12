class DivisionReferralCity < ActiveRecord::Base
  belongs_to :division
  belongs_to :city

  has_many :division_referral_city_specializations, :dependent => :destroy
  has_many :specializations, :through => :division_referral_city_specializations

  include PaperTrailable
end
