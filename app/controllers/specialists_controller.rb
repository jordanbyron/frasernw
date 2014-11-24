class SpecialistsController < ApplicationController
  skip_before_filter :login_required, :only => :refresh_cache
  load_and_authorize_resource :except => :refresh_cache
  before_filter :check_token, :only => :refresh_cache
  skip_authorization_check :only => :refresh_cache
  include ApplicationHelper
  
  cache_sweeper :specialist_sweeper, :only => [:create, :update, :update_photo, :accept, :destroy]

  def index
    if params[:specialization_id].present?
      @specializations = [Specialization.find(params[:specialization_id])]
    else
      @specializations = Specialization.all
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @specialist = Specialist.find(params[:id])
    @feedback = @specialist.feedback_items.build
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @is_new = true
    @is_review = false
    #specialization passed in to facilitate javascript "checking off" of starting speciality, since build below doesn't seem to work
    @specialization = Specialization.find(params[:specialization_id])     
    @specialist = Specialist.new
    @specialist.specialist_specializations.build( :specialization_id => @specialization.id )
    while @specialist.specialist_offices.length < Specialist::MAX_OFFICES
      so = @specialist.specialist_offices.build
      s = so.build_phone_schedule
      s.build_monday
      s.build_tuesday
      s.build_wednesday
      s.build_thursday
      s.build_friday
      s.build_saturday
      s.build_sunday
      o = so.build_office
      l = o.build_location
      l.build_address
    end
    @offices = Office.includes(:location => [ {:address => :city}, {:location_in => [{:address => :city}, {:hospital_in => {:location => {:address => :city}}}]}, {:hospital_in => {:location => {:address => :city}}} ]).all.reject{|o| o.empty? }.sort{|a,b| "#{a.city} #{a.short_address}" <=> "#{b.city} #{b.short_address}"}.collect{|o| ["#{o.short_address}, #{o.city}", o.id]}
    @specializations_clinics = (current_user_is_super_admin? ? @specialization.clinics : @specialization.clinics.in_divisions(current_user_divisions)).map{ |c| c.locations }.flatten.map{ |l| ["#{l.locatable.clinic.name} - #{l.short_address}", l.id] }
    @specializations_clinic_locations = (current_user_is_super_admin? ? @specialization.clinics : @specialization.clinics.in_divisions(current_user_divisions)).map{ |c| c.clinic_locations.reject{ |cl| cl.empty? } }.flatten.map{ |cl| ["#{cl.clinic.name} - #{cl.location.short_address}", cl.id] }
    @specializations_procedures = ancestry_options( @specialization.non_assumed_procedure_specializations_arranged )
    @capacities = []
    @specialization.non_assumed_procedure_specializations_arranged.each { |ps, children|
      @capacities << generate_capacity(nil, ps, 0)
      children.each { |child_ps, grandchildren|
        @capacities << generate_capacity(nil, child_ps, 1)
        grandchildren.each { |grandchild_ps, greatgrandchildren|
          @capacities << generate_capacity(nil, grandchild_ps, 2)
        }
      }
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    #can only have one of office_id or office_attributes, otherwise create gets confused
    params[:specialist][:specialist_offices_attributes].each{ |so_key, so_value|
      if so_value[:office_id].blank?
        so_value.delete(:office_id)
      else
        so_value.delete(:office_attributes)
      end
    }
    @specialist = Specialist.new(params[:specialist])
    if @specialist.save!
      if params[:capacities_mapped].present?
        specialist_specializations = @specialist.specializations
        params[:capacities_mapped].each do |updated_capacity, value|
          capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, updated_capacity)
          capacity.investigation = params[:capacities_investigations][updated_capacity]
          capacity.waittime_mask = params[:capacities_waittime][updated_capacity] if params[:capacities_waittime].present?
          capacity.lagtime_mask = params[:capacities_lagtime][updated_capacity] if params[:capacities_lagtime].present?
          capacity.save
          
          #save any other capacities that have the same procedure and are in a specialization our specialist is in
          capacity.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !specialist_specializations.include?(ps2.specialization) }.map{ |ps2| Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, ps2.id) }.map{ |c| c.save }
        end
      end
      @specialist.review_object = ActiveSupport::JSON::encode(params)
      @specialist.save
      redirect_to @specialist, :notice => "Successfully created #{@specialist.name}. #{undo_link}"
    else
      render :action => 'new'
    end
  end

  def edit
    @is_new = false
    @is_review = false
    @is_rereview = false
    @specialist = Specialist.find(params[:id])
    if @specialist.capacities.count == 0
      @specialist.capacities.build
    end
    while @specialist.specialist_offices.length < Specialist::MAX_OFFICES
      os = @specialist.specialist_offices.build
      s = os.build_phone_schedule
      s.build_monday
      s.build_tuesday
      s.build_wednesday
      s.build_thursday
      s.build_friday
      s.build_saturday
      s.build_sunday
      o = os.build_office
      l = o.build_location
    end
    @offices = Office.includes(:location => [ {:address => :city}, {:location_in => [{:address => :city}, {:hospital_in => {:location => {:address => :city}}}]}, {:hospital_in => {:location => {:address => :city}}} ]).all.reject{|o| o.empty? }.sort{|a,b| "#{a.city} #{a.short_address}" <=> "#{b.city} #{b.short_address}"}.collect{|o| ["#{o.short_address}, #{o.city}", o.id]}
    @specializations_clinics = []
    @specializations_clinic_locations = []
    @specialist.specializations.each { |s|
      @specializations_clinics += (current_user_is_super_admin? ? s.clinics : s.clinics.in_divisions(current_user_divisions)).map{ |c| c.locations }.flatten.map{ |l| ["#{l.locatable.clinic.name} - #{l.short_address}", l.id] }
      @specializations_clinic_locations += (current_user_is_super_admin? ? s.clinics : s.clinics.in_divisions(current_user_divisions)).map{ |c| c.clinic_locations.reject{ |cl| cl.empty? } }.flatten.map{ |cl| ["#{cl.clinic.name} - #{cl.location.short_address}", cl.id] }
    }
    @specializations_clinics.sort!
    @specializations_clinic_locations.sort!
    @specializations_procedures = []
    procedure_specializations = {}
    @specialist.specializations.each { |s|
      @specializations_procedures << [ "----- #{s.name} -----", nil ] if @specialist.specializations.count > 1
      @specializations_procedures += ancestry_options( s.non_assumed_procedure_specializations_arranged )
      procedure_specializations.merge!(s.non_assumed_procedure_specializations_arranged)
    }
    capacities_procedure_list = []
    @capacities = []
    procedure_specializations.each { |ps, children|
      if !capacities_procedure_list.include?(ps.procedure.id)
        @capacities << generate_capacity(@specialist, ps, 0)
        capacities_procedure_list << ps.procedure.id
      end
      children.each { |child_ps, grandchildren|
        if !capacities_procedure_list.include?(child_ps.procedure.id)
          @capacities << generate_capacity(@specialist, child_ps, 1)
          capacities_procedure_list << child_ps.procedure.id
        end
        grandchildren.each { |grandchild_ps, greatgrandchildren|
          if !capacities_procedure_list.include?(grandchild_ps.procedure.id)
            @capacities << generate_capacity(@specialist, grandchild_ps, 2)
            capacities_procedure_list << grandchild_ps.procedure.id
          end
        }
      }
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @specialist = Specialist.find(params[:id])
    SpecialistSweeper.instance.before_controller_update(@specialist)
    if @specialist.update_attributes(params[:specialist])
      if params[:capacities_mapped].present?
        specialist_specializations = @specialist.specializations
        @specialist.capacities.each do |original_capacity|
          Capacity.destroy(original_capacity.id) if params[:capacities_mapped][original_capacity.procedure_specialization.id.to_s].blank?
        end
        params[:capacities_mapped].each do |updated_capacity, value|
          capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, updated_capacity)
          capacity.investigation = params[:capacities_investigations][updated_capacity]
          capacity.waittime_mask = params[:capacities_waittime][updated_capacity] if params[:capacities_waittime].present?
          capacity.lagtime_mask = params[:capacities_lagtime][updated_capacity] if params[:capacities_lagtime].present?
          capacity.save
          
          #save any other capacities that have the same procedure and are in a specialization our specialist is in
          capacity.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !specialist_specializations.include?(ps2.specialization) }.map{ |ps2| Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, ps2.id) }.map{ |c| c.save }
        end
      else
        #destroy all capacities, as they must have edited to have none
        @specialist.capacities.each do |original_capacity|
          Capacity.destroy(original_capacity.id)
        end
      end
      @specialist.review_object = ActiveSupport::JSON::encode(params)
      @specialist.save
      redirect_to @specialist, :notice => "Successfully updated #{@specialist.name}. #{undo_link}"
    else
      render :edit
    end
  end

  def accept
    #accept changes, archive the review item so that we can save the specialist
    @specialist = Specialist.find(params[:id])
    
    review_item = @specialist.review_item
    
    if review_item.blank?
      redirect_to specialist_path(@specialist), :notice => "There are no review items for this specialist"
    else
      review_item.archived = true;
      review_item.save
      
      SpecialistSweeper.instance.before_controller_update(@specialist)
      if @specialist.update_attributes(params[:specialist])
        if params[:capacities_mapped].present?
          specialist_specializations = @specialist.specializations
          @specialist.capacities.each do |original_capacity|
            Capacity.destroy(original_capacity.id) if params[:capacities_mapped][original_capacity.procedure_specialization.id.to_s].blank?
          end
          params[:capacities_mapped].each do |updated_capacity, value|
            capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, updated_capacity)
            capacity.investigation = params[:capacities_investigations][updated_capacity]
            capacity.waittime_mask = params[:capacities_waittime][updated_capacity] if params[:capacities_waittime].present?
            capacity.lagtime_mask = params[:capacities_lagtime][updated_capacity] if params[:capacities_lagtime].present?
            capacity.save
            
            #save any other capacities that have the same procedure and are in a specialization our specialist is in
            capacity.procedure_specialization.procedure.procedure_specializations.reject{ |ps2| !specialist_specializations.include?(ps2.specialization) }.map{ |ps2| Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, ps2.id) }.map{ |c| c.save }
          end
        end
        @specialist.update_attributes( :address_update => "" )
        @specialist.review_object = ActiveSupport::JSON::encode(params)
        @specialist.save
        redirect_to @specialist, :notice => "Successfully updated #{@specialist.name}. #{undo_link}"
      else
        render :edit
      end
    end
  end
  
  def archive
    #archive the review item so that we can save the specialist
    @specialist = Specialist.find(params[:id])
    
    review_item = @specialist.review_item
    
    if review_item.blank?
      redirect_to specialist_path(@specialist), :notice => "There are no review items for this specialist"
    else
      review_item.archived = true;
      review_item.save
      redirect_to review_items_path, :notice => "Successfully archived review item for #{@specialist.name}."
    end
  end

  def destroy
    @specialist = Specialist.find(params[:id])
    SpecialistSweeper.instance.before_controller_destroy(@specialist)
    name = @specialist.name;
    @specialist.destroy
    redirect_to specialists_url, :notice => "Successfully deleted #{name}. #{undo_link}"
  end

  def undo_link
    #view_context.link_to("undo", revert_version_path(@specialist.versions.scoped.last), :method => :post).html_safe
  end
  
  def review
    @is_new = false
    @is_review = false
    @is_rereview = false
    @specialist = Specialist.find(params[:id])
    @review_item = @specialist.review_item;
    
    if @review_item.blank?
      redirect_to specialists_path, :notice => "There are no review items for this specialist"
      else
      while @specialist.specialist_offices.length < Specialist::MAX_OFFICES
        os = @specialist.specialist_offices.build
        s = os.build_phone_schedule
        s.build_monday
        s.build_tuesday
        s.build_wednesday
        s.build_thursday
        s.build_friday
        s.build_saturday
        s.build_sunday
        o = os.build_office
        l = o.build_location
      end
      @offices = Office.includes(:location => [ {:address => :city}, {:location_in => [{:address => :city}, {:hospital_in => {:location => {:address => :city}}}]}, {:hospital_in => {:location => {:address => :city}}} ]).all.reject{|o| o.empty? }.sort{|a,b| "#{a.city} #{a.short_address}" <=> "#{b.city} #{b.short_address}"}.collect{|o| ["#{o.short_address}, #{o.city}", o.id]}
      @specializations_clinics = []
      @specializations_clinic_locations = []
      @specialist.specializations.each { |s|
        @specializations_clinics += s.clinics.map{ |c| c.locations }.flatten.map{ |l| ["#{l.locatable.clinic.name} - #{l.short_address}", l.id] }
        @specializations_clinic_locations += (current_user_is_super_admin? ? s.clinics : s.clinics.in_divisions(current_user_divisions)).map{ |c| c.clinic_locations.reject{ |cl| cl.empty? } }.flatten.map{ |cl| ["#{cl.clinic.name} - #{cl.location.short_address}", cl.id] }
      }
      @specializations_clinics.sort!
      @specializations_clinic_locations.sort!
      @specializations_procedures = []
      procedure_specializations = {}
      @specialist.specializations.each { |s|
        @specializations_procedures << [ "----- #{s.name} -----", nil ] if @specialist.specializations.count > 1
        @specializations_procedures += ancestry_options( s.non_assumed_procedure_specializations_arranged )
        procedure_specializations.merge!(s.non_assumed_procedure_specializations_arranged)
      }
      capacities_procedure_list = []
      @capacities = []
      procedure_specializations.each { |ps, children|
        if !capacities_procedure_list.include?(ps.procedure.id)
          @capacities << generate_capacity(@specialist, ps, 0)
          capacities_procedure_list << ps.procedure.id
        end
        children.each { |child_ps, grandchildren|
          if !capacities_procedure_list.include?(child_ps.procedure.id)
            @capacities << generate_capacity(@specialist, child_ps, 1)
            capacities_procedure_list << child_ps.procedure.id
          end
          grandchildren.each { |grandchild_ps, greatgrandchildren|
            if !capacities_procedure_list.include?(grandchild_ps.procedure.id)
              @capacities << generate_capacity(@specialist, grandchild_ps, 2)
              capacities_procedure_list << grandchild_ps.procedure.id
            end
          }
        }
      }
      render :template => 'specialists/edit', :layout => request.headers['X-PJAX'] ? 'ajax' : true
    end
  end
  
  def rereview
    @is_new = false
    @is_review = false
    @is_rereview = true
    @specialist = Specialist.find(params[:id])
    @review_item = ReviewItem.find(params[:review_item_id])
    
    if @review_item.blank?
      redirect_to specialists_path, :notice => "There are no review items for this specialist"
    elsif @review_item.base_object.blank?
      redirect_to specialists_path, :notice => "There is no base review item for this specialist to re-review from"
    else
      while @specialist.specialist_offices.length < Specialist::MAX_OFFICES
        os = @specialist.specialist_offices.build
        s = os.build_phone_schedule
        s.build_monday
        s.build_tuesday
        s.build_wednesday
        s.build_thursday
        s.build_friday
        s.build_saturday
        s.build_sunday
        o = os.build_office
        l = o.build_location
      end
      @offices = Office.includes(:location => [ {:address => :city}, {:location_in => [{:address => :city}, {:hospital_in => {:location => {:address => :city}}}]}, {:hospital_in => {:location => {:address => :city}}} ]).all.reject{|o| o.empty? }.sort{|a,b| "#{a.city} #{a.short_address}" <=> "#{b.city} #{b.short_address}"}.collect{|o| ["#{o.short_address}, #{o.city}", o.id]}
      @specializations_clinics = []
      @specializations_clinic_locations = []
      @specialist.specializations.each { |s|
        @specializations_clinics += s.clinics.map{ |c| c.locations }.flatten.map{ |l| ["#{l.locatable.clinic.name} - #{l.short_address}", l.id] }
        @specializations_clinic_locations += (current_user_is_super_admin? ? s.clinics : s.clinics.in_divisions(current_user_divisions)).map{ |c| c.clinic_locations.reject{ |cl| cl.empty? } }.flatten.map{ |cl| ["#{cl.clinic.name} - #{cl.location.short_address}", cl.id] }
      }
      @specializations_clinics.sort!
      @specializations_clinic_locations.sort!
      @specializations_procedures = []
      procedure_specializations = {}
      @specialist.specializations.each { |s|
        @specializations_procedures << [ "----- #{s.name} -----", nil ] if @specialist.specializations.count > 1
        @specializations_procedures += ancestry_options( s.non_assumed_procedure_specializations_arranged )
        procedure_specializations.merge!(s.non_assumed_procedure_specializations_arranged)
      }
      capacities_procedure_list = []
      @capacities = []
      procedure_specializations.each { |ps, children|
        if !capacities_procedure_list.include?(ps.procedure.id)
          @capacities << generate_capacity(@specialist, ps, 0)
          capacities_procedure_list << ps.procedure.id
        end
        children.each { |child_ps, grandchildren|
          if !capacities_procedure_list.include?(child_ps.procedure.id)
            @capacities << generate_capacity(@specialist, child_ps, 1)
            capacities_procedure_list << child_ps.procedure.id
          end
          grandchildren.each { |grandchild_ps, greatgrandchildren|
            if !capacities_procedure_list.include?(grandchild_ps.procedure.id)
              @capacities << generate_capacity(@specialist, grandchild_ps, 2)
              capacities_procedure_list << grandchild_ps.procedure.id
            end
          }
        }
      }
      render :template => 'specialists/edit', :layout => request.headers['X-PJAX'] ? 'ajax' : true
    end
  end
  
  def edit_referral_forms
    @entity = Specialist.find(params[:id])
    @entity.referral_forms.build if @entity.referral_forms.length == 0
    @entity_type = "office"
    render :template => 'referral_form/edit', :layout => request.headers['X-PJAX'] ? 'ajax' : true 
  end
  
  def print_patient_information
    @specialist = Specialist.find(params[:id])
    @specialist_office = @specialist.specialist_offices.reject{ |so| so.empty? }.first
    render :layout => 'print'
  end
  
  def print_office_patient_information
    @specialist = Specialist.find(params[:id])
    @specialist_office = SpecialistOffice.find(params[:office_id])
    render :print_patient_information, :layout => 'print'
  end
  
  def photo
    @specialist = Specialist.find(params[:id])
    render :layout => request.headers['X-PJAX'] ? 'ajax' : true
  end
  
  def update_photo
    @specialist = Specialist.find(params[:id])
    SpecialistSweeper.instance.before_controller_update(@specialist)
    if @specialist.update_attributes(params[:specialist])
      redirect_to @specialist, :notice  => "Successfully updated #{@specialist.formal_name}'s photo."
    else
      render :action => 'photo'
    end
  end
  
  def check_token
    token_required( Specialist, params[:token], params[:id] )
  end
  
  def refresh_cache
    @specialist = Specialist.find(params[:id])
    @feedback = @specialist.feedback_items.build
    render :show, :layout => 'ajax'
  end
  
  protected
    def generate_capacity(specialist, procedure_specialization, offset)
      capacity = specialist.present? ? Capacity.find_by_specialist_id_and_procedure_specialization_id(specialist.id, procedure_specialization.id) : nil
      return {
        :mapped => capacity.present?,
        :name => procedure_specialization.procedure.name,
        :id => procedure_specialization.id,
        :investigations => capacity.present? ? capacity.investigation : "",
        :custom_wait_time => procedure_specialization.specialist_wait_time?,
        :waittime => capacity.present? ? capacity.waittime_mask : 0,
        :lagtime => capacity.present? ? capacity.lagtime_mask : 0,
        :offset => offset
      }
    end
end
