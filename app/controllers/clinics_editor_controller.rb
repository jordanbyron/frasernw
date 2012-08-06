class ClinicsEditorController < ApplicationController
  include ApplicationHelper
  skip_before_filter :login_required
  skip_authorization_check
  before_filter :check_pending, :except => :pending
  before_filter :check_token
  
  def edit
    @token = params[:token]
    @is_review = true
    @clinic = Clinic.find(params[:id])
    @review_item = @clinic.review_item;
    if @clinic.focuses.count == 0
      @clinic.focuses.build
    end
    @specializations_clinics = []
    @clinic.specializations_including_in_progress.each { |s| 
      @specializations_clinics += s.clinics.collect { |c| [c.name, c.id] }
    }
    @specializations_clinics.sort!
    @specializations_procedures = []
    procedure_specializations = {}
    @clinic.specializations_including_in_progress.each { |s| 
      @specializations_procedures << [ "----- #{s.name} -----", nil ] if @clinic.specializations_including_in_progress.count > 1
      @specializations_procedures += ancestry_options( s.non_assumed_procedure_specializations_arranged )
      procedure_specializations.merge!(s.non_assumed_procedure_specializations_arranged)
    }
    @focuses = []
    procedure_specializations.each { |ps, children|
      focus = Focus.find_by_clinic_id_and_procedure_specialization_id(@clinic.id, ps.id)
      if focus.present?
        @focuses << { :mapped => true, :name => ps.procedure.name, :id => ps.id, :investigations => focus.investigation, :offset => 0 }
        else
        @focuses << { :mapped => false, :name => ps.procedure.name, :id => ps.id, :investigations => "", :offset => 0 }
      end
      children.each { |child_ps, grandchildren|
        focus = Focus.find_by_clinic_id_and_procedure_specialization_id(@clinic.id, child_ps.id)
        if focus.present?
          @focuses << { :mapped => true, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => focus.investigation, :offset => 1 }
          else
          @focuses << { :mapped => false, :name => child_ps.procedure.name, :id => child_ps.id, :investigations => "", :offset => 1 }
        end
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
    review_item.whodunnit = current_user.id if current_user.present?
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

end
