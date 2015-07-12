class ReferralFormsController < ApplicationController
  load_and_authorize_resource except: [:edit, :update]

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

  def edit
    parent_klass = params[:parent_type].constantize
    @entity = parent_klass.find params[:parent_id]

    authorize! :edit, @entity

    @entity.referral_forms.build if @entity.referral_forms.length == 0
    @entity_type = @entity.class == Clinic ? "clinic" : "office"

    render(
      template: 'referral_forms/edit',
      layout: request.headers['X-PJAX'] ? 'ajax' : true
    )
  end

  def update
    parent_klass = params[:parent_type].constantize
    @entity = parent_klass.find params[:parent_id]

    authorize! :update, @entity

    entity_param_key = params[:parent_type].downcase.to_sym
    @entity.update_attributes params[entity_param_key]

    cache_path = begin
      if parent_klass == Clinic
        clinic_path(@entity)
      else
        specialist_path(@entity)
      end
    end
    expire_fragment cache_path

    redirect_to @entity, :notice  => "Successfully updated #{@entity.name}."
  end
end
