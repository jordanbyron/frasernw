class ReferralFormsController < ApplicationController
  load_and_authorize_resource

  def index
    user_divisions = current_user_divisions

    @referral_forms = []

    Specialization.all.each do |specialization|
      cities = current_user.divisions.map{ |d| d.local_referral_cities_for_specialization(specialization) }.flatten.uniq
      @referral_forms += specialization.specialists.in_cities(cities).map{ |s| s.referral_forms }.flatten
      @referral_forms += specialization.clinics.in_cities(cities).map{ |c| c.referral_forms }.flatten
    end

    @referral_forms.uniq!

    render :layout => 'ajax' if request.headers['X-PJAX']
  end
end
