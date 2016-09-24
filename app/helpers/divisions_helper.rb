module DivisionsHelper

  def included_city(city)
    @local_referral_cities.include?(city.id) &&
      @local_referral_cities[city.id].present?
  end

  def included_specialization(city, specialization)
    (@local_referral_cities[city.id].present?) &&
      (@local_referral_cities[city.id].include? specialization.id)
  end

end
