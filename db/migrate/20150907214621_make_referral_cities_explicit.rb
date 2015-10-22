class MakeReferralCitiesExplicit < ActiveRecord::Migration
  def up
    def old_local_referral_cities(division, specialization)
      refined_cities = division.division_referral_city_specializations.reject{ |drcs| drcs.specialization_id != specialization.id }.map{ |drcs| drcs.division_referral_city.city }
      if refined_cities.present?
        #division has overriden this specialty
        return refined_cities
      else
        #division has not overriden this specialty
        return division.cities
      end
    end

    Division.all.each do |division|
      Specialization.all.each do |specialization|
        old_local_referral_cities(division, specialization).each do |city|
          DivisionReferralCitySpecialization.find_or_create_by(
            division: division,
            specialization: specialization,
            city: city
          )
        end
      end
    end

    # test
    # Division.all.each do |division|
    #   Specialization.all.each do |specialization|
    #     if old_local_referral_cities(division, specialization).sort != division.local_referral_cities(specialization).sort
    #       raise "error"
    #     end
    #   end
    # end
  end

  def down
  end
end
