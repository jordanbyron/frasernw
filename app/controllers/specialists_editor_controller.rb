class SpecialistsEditorController < ApplicationController
  include ApplicationHelper
  skip_before_filter :login_required
  skip_authorization_check
  before_filter :check_pending, :except => :pending
  before_filter :check_token
  
  def edit
    @token = params[:token]
    @is_review = true
    @specialist = Specialist.find(params[:id])
    @review_item = @specialist.review_item
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
    @view = @specialist.views.build(:notes => request.remote_ip)
    @view.save
    if request.headers['X-PJAX']
      render :template => 'specialists/edit', :layout => 'ajax'
    else
      render :template => 'specialists/edit'
    end
  end

  def update
    @specialist = Specialist.find(params[:id])
    
    ReviewItem.delete(@specialist.review_item) if @specialist.review_item.present?
    
    review_item = ReviewItem.new
    review_item.item_type = "Specialist"
    review_item.item_id = @specialist.id
    review_item.object = ActiveSupport::JSON::encode(params)
    review_item.whodunnit = current_user.id if current_user.present?
    review_item.save
    
    render :layout => 'ajax'
  end
  
  def pending
    @specialist = Specialist.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def check_pending
    specialist = Specialist.find(params[:id])
    redirect_to specialist_self_pending_path(specialist) if specialist.review_item.present? && (!current_user || (specialist.review_item.whodunnit != current_user.id.to_s))
  end
  
  def check_token
    token_required( Specialist, params[:token], params[:id] )
  end

end
