class ScItemsController < ApplicationController
  include ScCategoriesHelper
  load_and_authorize_resource
  before_filter :authorize_division_for_user, :only => :index
  
  def index
    @division = Division.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @sc_item = ScItem.find(params[:id])
    @feedback = @sc_item.feedback_items.build
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @sc_item = ScItem.new
    new_sc_item_preload
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @sc_item = ScItem.new(params[:sc_item])
    params[:specialization] = {} if params[:specialization].blank?
    params[:procedure_specialization] = {} if params[:procedure_specialization].blank?
    if @sc_item.save
      params[:specialization].each do |specialization_id, set|
        @sc_item.sc_item_specializations.create( :specialization_id => specialization_id )
      end
      params[:procedure_specialization].each do |ps_id, set|
        specialization = ProcedureSpecialization.find(ps_id).specialization
        sc_item_specialization = ScItemSpecialization.find_by_sc_item_id_and_specialization_id( @sc_item.id, specialization.id )
        ScItemSpecializationProcedureSpecialization.create( :sc_item_specialization_id => sc_item_specialization.id, :procedure_specialization_id => ps_id ) if sc_item_specialization.present?
      end
      create_sc_item_activity
      redirect_to @sc_item, :notice => "Successfully created content item."
    else
      new_sc_item_preload
      render :action => 'new'
    end
  end
  
  def edit
    @sc_item = ScItem.find(params[:id])
    @has_specializations = @sc_item.specializations.map{ |s| s.id }
    @has_procedure_specializations = @sc_item.procedure_specializations.map{ |ps| ps.id }
    @hierarchy = ancestry_options_limited(ScCategory.unscoped.arrange(:order => 'name'), nil)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @sc_item = ScItem.find(params[:id])
    params[:specialization] = {} if params[:specialization].blank?
    params[:procedure_specialization] = {} if params[:procedure_specialization].blank?
    if @sc_item.update_attributes(params[:sc_item])
      @sc_item.sc_item_specializations.each do |sis|
        #remove existing specializations that no longer exist
        ScItemSpecialization.destroy(sis.id) if !params[:specialization].include? sis.specialization_id
      end
      #DevNote: ^^potentially dangerous use of destroy
      params[:specialization].each do |specialization_id, set|
        #add new specializations
        ScItemSpecialization.find_or_create_by_sc_item_id_and_specialization_id( @sc_item.id, specialization_id )
      end
      @sc_item.sc_item_specialization_procedure_specializations.each do |sisps|
        #remove existing procedure specializations that no longer exist
        ScItemSpecializationProcedureSpecialization.destroy(sisps.id) if !params[:procedure_specialization].include? sisps.procedure_specialization_id
      end
      #DevNote: ^^potentially dangerous use of destroy
      params[:procedure_specialization].each do |ps_id, set|
        #add new procedure specializations
        specialization = ProcedureSpecialization.find(ps_id).specialization
        sc_item_specialization = ScItemSpecialization.find_by_sc_item_id_and_specialization_id( @sc_item.id, specialization.id )
        if sc_item_specialization.present?
          #parent specialization was checked off
          ScItemSpecializationProcedureSpecialization.find_or_create_by_sc_item_specialization_id_and_procedure_specialization_id( sc_item_specialization.id, ps_id )
        end
      end
      redirect_to @sc_item, :notice  => "Successfully updated content item."
      else
      render :action => 'edit'
    end
  end
  
  def destroy
    @sc_item = ScItem.find(params[:id])
    @sc_item.destroy
    redirect_to sc_items_url, :notice => "Successfully deleted content item."
  end
  
  private
  
  def authorize_division_for_user
    if !(current_user_is_super_admin? || (current_user_divisions.include? Division.find(params[:id])))
      redirect_to root_url, :notice => "You are not allowed to access this page"
    end
  end

  def new_sc_item_preload
    @has_specializations = []
    @has_procedure_specializations = []
    @hierarchy = ancestry_options_limited(ScCategory.unscoped.arrange(:order => 'name'), nil)
  end

  def create_sc_item_activity
    @sc_item.create_activity action: :create, parameters: {}, update_classification_type: Subscription.resource_update, type_mask: @sc_item.type_mask, type_mask_description: @sc_item.type, format_type: @sc_item.format_type, format_type_description: @sc_item.format, parent_id: @sc_item.sc_category.root.id, parent_type: @sc_item.sc_category.root.name, owner: @sc_item.division
  end
end
