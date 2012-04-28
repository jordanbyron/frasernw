class SpecialistsEditorController < ApplicationController
  include ApplicationHelper
  skip_before_filter :login_required
  skip_authorization_check
  before_filter { |controller|  controller.send(:token_required, Specialist, params[:token], params[:id]) }
  
  def edit
    @token      = params[:token]
    @specialist = Specialist.find(params[:id])
    if @specialist.capacities.count == 0
      @specialist.capacities.build
    end
    @specializations_clinics = []
    @specialist.specializations_including_in_progress.each { |s| 
      @specializations_clinics += s.clinics.collect { |c| [c.name, c.id] }
    }
    @specializations_clinics.sort!
    @specializations_procedures = []
    @specialist.specializations_including_in_progress.each { |s| 
      @specializations_procedures << [ "----- #{s.name} -----", nil ] if @specialist.specializations_including_in_progress.count > 1
      @specializations_procedures += ancestry_options( s.non_assumed_procedure_specializations_arranged )
    }
    @view = @specialist.views.build(:notes => request.remote_ip)
    @view.save
    render :template => 'specialists/edit'
  end

  def update
    @specialist = Specialist.find(params[:id])
    
    review_item = ReviewItem.new
    review_item.item_type = "Specialist"
    review_item.item_id = @specialist.id
    review_item.object = ActiveSupport::JSON::encode(params[:specialist])
    review_item.whodunnit = "Unknown"
    review_item.save
    
    redirect_to specialist_self_edit_path(@specialist), :notice => "You have successfully updated the information for #{@specialist.name}."
  end

end
