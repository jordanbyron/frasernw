class SpecialistsEditorController < ApplicationController
  include ApplicationHelper
  skip_before_filter :login_required
  skip_authorization_check
  before_filter :check_pending, :except => [:pending, :temp_edit, :temp_update]
  before_filter :check_token

  def edit
    @token = params[:token]
    @form_modifier = SpecialistFormModifier.new(:edit, current_user, token: true)
    @specialist = Specialist.find(params[:id])
    @review_item = @specialist.review_item
    if @specialist.capacities.count == 0
      @specialist.capacities.build
    end

    build_specialist_offices
    load_form_variables

    @specializations_clinics = []
    @specializations_clinic_locations = []
    @specialist.specializations.each { |s|
      @specializations_clinics += s.clinics.map{ |c| c.locations }.flatten.map{ |l| ["#{l.locatable.clinic.name} #{l.short_address}", l.id] }
      @specializations_clinic_locations += s.clinics.map{ |c| c.clinic_locations.reject{ |cl| cl.empty? } }.flatten.map{ |cl| ["#{cl.clinic.name} - #{cl.location.short_address}", cl.id] }
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
    review_item.base_object = @specialist.review_object
    review_item.whodunnit = current_user.id if current_user.present?
    review_item.status = params[:no_updates] ? ReviewItem::STATUS_NO_UPDATES: ReviewItem::STATUS_UPDATES
    review_item.save

    EventMailer.mail_review_queue_entry(review_item).deliver

    render
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

  private

  def load_form_variables
    @offices = Office.cached_all_formatted_for_form
    @hospitals = Hospital.all_formatted_for_form
  end

  def build_specialist_offices
    # build office & phone schedule.
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
    end
  end

end
