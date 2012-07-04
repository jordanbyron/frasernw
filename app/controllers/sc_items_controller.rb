class ScItemsController < ApplicationController
  load_and_authorize_resource
  
  #cache_sweeper :sc_item_sweeper, :only => [:create, :update, :destroy]
  
  def index
    @sc_items = ScItem.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @sc_item = ScItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @sc_item = ScItem.new
    @has_specializations = []
    @has_procedure_specializations = []
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @sc_item = ScItem.new(params[:sc_item])
    if @sc_item.save
      params[:specialization].each do |specialization_id, set|
        @sc_item.sc_item_specializations.create( :specialization_id => specialization_id )
      end
      params[:procedure_specialization].each do |ps_id, set|
        @sc_item.sc_item_procedure_specializations.create( :procedure_specialization_id => ps_id )
      end
      redirect_to @sc_item, :notice => "Successfully created sc_item."
    else
      render :action => 'new'
    end
  end
  
  def edit
    @sc_item = ScItem.find(params[:id])
    @has_specializations = @sc_item.specializations.map{ |s| s.id }
    @has_procedure_specializations = @sc_item.procedure_specializations.map{ |s| s.id }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @sc_item = ScItem.find(params[:id])
    #ScItemSweeper.instance.before_controller_update(@sc_item)
    if @sc_item.update_attributes(params[:sc_item])
      @sc_item.sc_item_specializations.each do |sis|
        #remove existing specializations that no longer exist
        ScItemSpecialization.destroy(sis.id) if !params[:specialization].include? sis.id
      end
      params[:specialization].each do |specialization_id, set|
        #add new specializations
        ScItemSpecialization.find_or_create_by_sc_item_id_and_specialization_id( @sc_item.id, specialization_id )
      end
      @sc_item.sc_item_procedure_specializations.each do |sips|
        #remove existing procedure specializations that no longer exist
        ScItemProcedureSpecialization.destroy(sips.id) if !params[:procedure_specialization].include? sips.id
      end
      params[:procedure_specialization].each do |ps_id, set|
        #add new procedure specializations
        ScItemProcedureSpecialization.find_or_create_by_sc_item_id_and_procedure_specialization_id( @sc_item.id, ps_id )
      end
      redirect_to @sc_item, :notice  => "Successfully updated sc_item."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @sc_item = ScItem.find(params[:id])
    #ScItemSweeper.instance.before_controller_destroy(@sc_item)
    @sc_item.destroy
    redirect_to sc_items_url, :notice => "Successfully deleted sc_item."
  end
end
