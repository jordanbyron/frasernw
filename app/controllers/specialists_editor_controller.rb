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
    render :template => 'specialists/edit'
  end

  def update
    @specialist = Specialist.find(params[:id])
    
    review_item = ReviewItem.new
    review_item.item_type = "Specialist"
    review_item.item_id = @specialist.id
    review_item.object = ActiveSupport::JSON::encode(params)
    review_item.whodunnit = "Unknown"
    review_item.save
    
    redirect_to specialist_self_edit_path(@specialist), :notice => "You have successfully updated the information for #{@specialist.name}."
  end

end
