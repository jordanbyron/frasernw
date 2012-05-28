class SpecialistsController < ApplicationController
  skip_before_filter :login_required, :only => :refresh_cache
  load_and_authorize_resource :except => :refresh_cache
  before_filter :check_token, :only => :refresh_cache
  skip_authorization_check :only => :refresh_cache
  include ApplicationHelper
  
  cache_sweeper :specialist_sweeper, :only => [:create, :update, :destroy]

  def index
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
      o = so.build_office
      l = o.build_location
      l.build_address
    end
    @offices = Office.includes(:location => [ {:address => :city}, {:clinic_in => {:location => [{:address => :city}, {:hospital_in => {:location => {:address => :city}}}]}}, {:hospital_in => {:location => {:address => :city}}} ]).all.reject{|o| o.empty? }.sort{|a,b| "#{a.city} #{a.short_address}" <=> "#{b.city} #{b.short_address}"}.collect{|o| ["#{o.short_address}, #{o.city}", o.id]}
    @specializations_clinics = @specialization.clinics.collect { |c| [c.name, c.id] }
    @specializations_procedures = ancestry_options( @specialization.non_assumed_procedure_specializations_arranged )
    @capacities = []
    @specialization.non_assumed_procedure_specializations_arranged.each { |ps, children|
      @capacities << { :mapped => false, :name => ps.procedure.name, :id => ps.id, :investigations => "", :offset => 0 }
      children.each { |child_ps, grandchildren|
        @capacities << { :mapped => false, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => "", :offset => 1 }
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
      params[:capacities_mapped].each do |updated_capacity, value|
        capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, updated_capacity)
        capacity.investigation = params[:capacities_investigations][updated_capacity]
        capacity.save
      end
      redirect_to @specialist, :notice => "Successfully created #{@specialist.name}. #{undo_link}"
    else
      render :action => 'new'
    end
  end

  def edit
    @is_new = false
    @is_review = false
    @specialist = Specialist.find(params[:id])
    if @specialist.capacities.count == 0
      @specialist.capacities.build
    end
    while @specialist.specialist_offices.length < Specialist::MAX_OFFICES
      os = @specialist.specialist_offices.build
      o = os.build_office
      l = o.build_location
    end
    @offices = Office.includes(:location => [ {:address => :city}, {:clinic_in => {:location => [{:address => :city}, {:hospital_in => {:location => {:address => :city}}}]}}, {:hospital_in => {:location => {:address => :city}}} ]).all.reject{|o| o.empty? }.sort{|a,b| "#{a.city} #{a.short_address}" <=> "#{b.city} #{b.short_address}"}.collect{|o| ["#{o.short_address}, #{o.city}", o.id]}
    @specializations_clinics = []
    @specialist.specializations_including_in_progress.each { |s| 
      @specializations_clinics += s.clinics.collect { |c| [c.name, c.id] }
    }
    @specializations_clinics.sort!
    @specializations_procedures = []
    procedure_specializations = {}
    @specialist.specializations_including_in_progress.each { |s| 
      @specializations_procedures << [ "----- #{s.name} -----", nil ] if @specialist.specializations_including_in_progress.count > 1
      @specializations_procedures += ancestry_options( s.non_assumed_procedure_specializations_arranged )
      procedure_specializations.merge!(s.non_assumed_procedure_specializations_arranged)
    }
    @capacities = []
    procedure_specializations.each { |ps, children|
      capacity = Capacity.find_by_specialist_id_and_procedure_specialization_id(@specialist.id, ps.id)
      if capacity.present?
        @capacities << { :mapped => true, :name => ps.procedure.name, :id => ps.id, :investigations => capacity.investigation, :offset => 0 }
      else
        @capacities << { :mapped => false, :name => ps.procedure.name, :id => ps.id, :investigations => "", :offset => 0 }
      end
      children.each { |child_ps, grandchildren|
        capacity = Capacity.find_by_specialist_id_and_procedure_specialization_id(@specialist.id, child_ps.id)
        if capacity.present?
          @capacities << { :mapped => true, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => capacity.investigation, :offset => 1 }
        else
          @capacities << { :mapped => false, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => "", :offset => 1 }
        end
      }
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @specialist = Specialist.find(params[:id])
    SpecialistSweeper.instance.before_controller_update(@specialist)
    if @specialist.update_attributes(params[:specialist])
      @specialist.capacities.each do |original_capacity|
        Capacity.destroy(original_capacity.id) if params[:capacities_mapped][original_capacity].blank?
      end
      params[:capacities_mapped].each do |updated_capacity, value|
        capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, updated_capacity)
        capacity.investigation = params[:capacities_investigations][updated_capacity]
        capacity.save
      end
      redirect_to @specialist, :notice => "Successfully updated #{@specialist.name}. #{undo_link}"
    else
      render :edit
    end
  end

  def accept
    #accept changes, destroy the review item so that we can save the specialist
    @specialist = Specialist.find(params[:id])
    
    review_item = @specialist.review_item
    ReviewItem.destroy(review_item)
    
    SpecialistSweeper.instance.before_controller_update(@specialist)
    if @specialist.update_attributes(params[:specialist])
      @specialist.capacities.each do |original_capacity|
        Capacity.destroy(original_capacity.id) if params[:capacities_mapped][original_capacity].blank?
      end
      params[:capacities_mapped].each do |updated_capacity, value|
        capacity = Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(@specialist.id, updated_capacity)
        capacity.investigation = params[:capacities_investigations][updated_capacity]
        capacity.save
      end
      redirect_to @specialist, :notice => "Successfully updated #{@specialist.name}. #{undo_link}"
    else
      render :edit
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

  def email
    @specialist = Specialist.find params[:id]
    #SpecialistMailer.invite_specialist(@specialist).deliver
    #@contact = @specialist.contacts.build(:user_id => current_user, :notes => @specialist.contact_email)
    #@contact.save
    redirect_to @specialist, :notice => "TODO"
  end
  
  def review
    @is_new = false
    @is_review = true
    @review_item = ReviewItem.find_by_item_type_and_item_id( "Specialist", params[:id] );
    
    if @review_item.blank?
      redirect_to specialists_path, :notice => "There are no review items for this specialist"
    else
      @specialist = Specialist.find(params[:id])
      @specializations_clinics = []
      @specialist.specializations_including_in_progress.each { |s| 
        @specializations_clinics += s.clinics.collect { |c| [c.name, c.id] }
      }
      @specializations_clinics.sort!
      @specializations_procedures = []
      procedure_specializations = {}
      @specialist.specializations_including_in_progress.each { |s| 
        @specializations_procedures << [ "----- #{s.name} -----", nil ] if @specialist.specializations_including_in_progress.count > 1
        @specializations_procedures += ancestry_options( s.non_assumed_procedure_specializations_arranged )
        procedure_specializations.merge!(s.non_assumed_procedure_specializations_arranged)
      }
      @capacities = []
      procedure_specializations.each { |ps, children|
        capacity = Capacity.find_by_specialist_id_and_procedure_specialization_id(@specialist.id, ps.id)
        if capacity.present?
          @capacities << { :mapped => true, :name => ps.procedure.name, :id => ps.id, :investigations => capacity.investigation, :offset => 0 }
        else
          @capacities << { :mapped => false, :name => ps.procedure.name, :id => ps.id, :investigations => "", :offset => 0 }
        end
        children.each { |child_ps, grandchildren|
          capacity = Capacity.find_by_specialist_id_and_procedure_specialization_id(@specialist.id, child_ps.id)
          if capacity.present?
            @capacities << { :mapped => true, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => capacity.investigation, :offset => 1 }
          else
            @capacities << { :mapped => false, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => "", :offset => 1 }
          end
        }
      }
      render :template => 'specialists/edit', :layout => 'ajax' if request.headers['X-PJAX']
    end
  end
  
  def edit_referral_forms
    @entity = Specialist.find(params[:id])
    @entity.referral_forms.build if @entity.referral_forms.length == 0
    @entity_type = "office"
    render :template => 'referral_form/edit', :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def print_patient_information
    @specialist = Specialist.find(params[:id])
    render :layout => 'print'
  end
  
  def check_token
    token_required( Specialist, params[:token], params[:id] )
  end
  
  def refresh_cache
    @specialist = Specialist.find(params[:id])
    @feedback = @specialist.feedback_items.build
    render :show, :layout => 'ajax'
  end
end
