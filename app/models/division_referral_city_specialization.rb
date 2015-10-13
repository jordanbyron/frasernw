class DivisionReferralCitySpecialization < ActiveRecord::Base
  belongs_to :division_referral_city
  belongs_to :specialization

  include PaperTrailable

  def self.find_or_create_by(args)
    find_by(args).presence || create_by(args)
  end

  def self.find_by(args)
    DivisionReferralCitySpecialization.
      joins(division_referral_city: [:city, :division]).
      where(specialization_id: args[:specialization].id).
      where(divisions: {id: args[:division].id}).
      where(cities: {id: args[:city].id}).
      first
  end

  def self.create_by(args)
    create(
      division_referral_city_id: DivisionReferralCity.find_or_create_by(args.slice(:division, :city)).id,
      specialization_id: args[:specialization].id
    )
  end

  def city_id
    division_referral_city.city_id
  end

  def city
    division_referral_city.city
  end

end
