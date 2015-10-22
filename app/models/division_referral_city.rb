class DivisionReferralCity < ActiveRecord::Base
  belongs_to :division
  belongs_to :city

  has_many :division_referral_city_specializations, :dependent => :destroy
  has_many :specializations, :through => :division_referral_city_specializations

  include PaperTrailable
  include ActionView::Helpers::FormOptionsHelper

  def self.save_all_for_division(division, priorities = {})
    City.all.each do |city|
      division_referral_city = DivisionReferralCity.
        find_or_initialize_by_division_id_and_city_id(division.id, city.id)

      division_referral_city.priority = (priorities[city.id.to_s] || City::PRIORITY_SETTINGS).to_i
      division_referral_city.save
    end
  end

  def self.find_by(args)
    self.joins(:division, :city).where(
      divisions: {id: args[:division].id },
      cities: {id: args[:city].id }
    ).first
  end

  def self.find_or_create_by(args)
    find_by(args).presence || create(
      division_id: args[:division].id,
      city_id: args[:city].id
    )
  end

  def options_for_priority_select
    options_for_select(
      City.priority_setting_options,
      self.priority
    )
  end
end
