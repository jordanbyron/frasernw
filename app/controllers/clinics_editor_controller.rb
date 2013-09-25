class ClinicsEditorController < ApplicationController
  include ApplicationHelper
  skip_before_filter :login_required
  skip_authorization_check
  before_filter :check_pending, :except => :pending
  before_filter :check_token
  
  def edit
    @token = params[:token]
    @is_review = true
    @is_rereview = false
    @clinic = Clinic.find(params[:id])
    @review_item = @clinic.review_item;
    if @clinic.focuses.count == 0
      @clinic.focuses.build
    end
    while @clinic.clinic_locations.length < Clinic::MAX_LOCATIONS
      cl = @clinic.clinic_locations.build
      s = cl.build_schedule
      s.build_monday
      s.build_tuesday
      s.build_wednesday
      s.build_thursday
      s.build_friday
      s.build_saturday
      s.build_sunday
      l = cl.build_location
      l.build_address
    end
    @specializations_procedures = []
    procedure_specializations = {}
    @clinic.specializations.each { |s| 
      @specializations_procedures << [ "----- #{s.name} -----", nil ] if @clinic.specializations.count > 1
      @specializations_procedures += ancestry_options( s.non_assumed_procedure_specializations_arranged )
      procedure_specializations.merge!(s.non_assumed_procedure_specializations_arranged)
    }
    focuses_procedure_list = []
    @focuses = []
    procedure_specializations.each { |ps, children|
      if !focuses_procedure_list.include?(ps.procedure.id)
        @focuses << generate_focus(@clinic, ps, 0)
        focuses_procedure_list << ps.procedure.id
      end
      children.each { |child_ps, grandchildren|
        if !focuses_procedure_list.include?(child_ps.procedure.id)
          @focuses << generate_focus(@clinic, child_ps, 1)
          focuses_procedure_list << child_ps.procedure.id
        end
        grandchildren.each { |grandchild_ps, greatgrandchildren|
          if !focuses_procedure_list.include?(grandchild_ps.procedure.id)
            @focuses << generate_focus(@clinic, grandchild_ps, 2)
            focuses_procedure_list << grandchild_ps.procedure.id
          end
        }
      }
    }
    if request.headers['X-PJAX']
      render :template => 'clinics/edit', :layout => 'ajax'
    else
      render :template => 'clinics/edit'
    end
  end

  def update
    @clinic = Clinic.find(params[:id])
    
    ReviewItem.delete(@clinic.review_item) if @clinic.review_item.present?
    
    review_item = ReviewItem.new
    review_item.item_type = "Clinic"
    review_item.item_id = @clinic.id
    review_item.object = ActiveSupport::JSON::encode(params)
    review_item.base_object = @clinic.review_object
    review_item.whodunnit = current_user.id if current_user.present?
    review_item.status = params[:no_updates] ? ReviewItem::STATUS_NO_UPDATES: ReviewItem::STATUS_UPDATES
    review_item.save
    
    render :layout => 'ajax'
  end
  
  def pending
    @clinic = Clinic.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def check_pending
    clinic = Clinic.find(params[:id])
    redirect_to clinic_self_pending_path(clinic) if clinic.review_item.present? && (!current_user || (clinic.review_item.whodunnit != current_user.id.to_s))
  end
  
  def check_token
    token_required( Clinic, params[:token], params[:id] )
  end
  
  protected
  def generate_focus(clinic, procedure_specialization, offset)
    focus = clinic.present? ? Focus.find_by_clinic_id_and_procedure_specialization_id(clinic.id, procedure_specialization.id) : nil
    return {
      :mapped => focus.present?,
      :name => procedure_specialization.procedure.name,
      :id => procedure_specialization.id,
      :investigations => focus.present? ? focus.investigation : "",
      :custom_wait_time => procedure_specialization.clinic_wait_time?,
      :waittime => focus.present? ? focus.waittime_mask : 0,
      :lagtime => focus.present? ? focus.lagtime_mask : 0,
      :offset => offset
    }
  end

end
