class SpecialistsController < ApplicationController
  load_and_authorize_resource
  include ApplicationHelper

  def index
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @specialist = Specialist.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    #specialization passed in to facilitate javascript "checking off" of starting speciality, since build below doesn't seem to work
    @specialization = Specialization.find(params[:specialization_id])     
    @specialist = Specialist.new
    @specialist.specialist_specializations.build( :specialization_id => @specialization.id )
    @specialist.capacities.build
    @specialist.addresses.build
    @specializations_clinics = @specialization.clinics.collect { |c| [c.name, c.id] }
    @specializations_procedures = ancestry_options( @specialization.procedure_specializations_arranged )
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @specialist = Specialist.new(params[:specialist])
    if @specialist.save!
      redirect_to @specialist, :notice => "Successfully created specialist. #{undo_link}"
    else
      render :action => 'new'
    end
  end

  def edit
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
      @specializations_procedures += ancestry_options( s.procedure_specializations_arranged )
    }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @specialist = Specialist.find(params[:id])
    if @specialist.update_attributes(params[:specialist])
      redirect_to @specialist, :notice => "Successfully updated specialist. #{undo_link}"
    else
      render :edit
    end
  end

  def destroy
    @specialist = Specialist.find(params[:id])
    @specialist.destroy
    redirect_to specialists_url, :notice => "Successfully deleted specialist. #{undo_link}"
  end

  def undo_link
    #view_context.link_to("undo", revert_version_path(@specialist.versions.scoped.last), :method => :post).html_safe
  end

  def email
    @specialist = Specialist.find params[:id]
    SpecialistMailer.invite_specialist(@specialist).deliver
    @contact = @specialist.contacts.build(:user_id => current_user, :notes => @specialist.contact_email)
    @contact.save
    redirect_to @specialist, :notice => "Sent email to #{@specialist.contact_email}"
  end
  
  def review
    @review_item = ReviewItem.find_by_item_type_and_item_id( "Specialist", params[:id] );
    
    if @review_item.blank?
      redirect_to specialists_path, :notice => "There are no review items for this specialist"
    else
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
        @specializations_procedures += ancestry_options( s.procedure_specializations_arranged )
      }
      render :template => 'specialists/edit', :layout => 'ajax' if request.headers['X-PJAX']
    end
  end
end
