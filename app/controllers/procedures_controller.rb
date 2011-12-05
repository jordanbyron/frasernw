class ProceduresController < ApplicationController
  load_and_authorize_resource
  
  def index
    if params[:specialization_id] != nil
      @specialization = Specialization.find params[:specialization_id]
      @procedures = @specialization.procedures
      redirect_to specialization_procedures_path(@specialization, @specialization.procedures) and return
    else
      redirect_to specialization_path(@specialization) and return
    end
  end
  
  def show
    @procedure = Procedure.find(params[:id])
    if request.headers['X-PJAX']
      render :layout => false
    end
  end
  
  def new
    @specialization = Specialization.find(params[:specialization_id])
    @procedure = Procedure.new :specialization_id => @specialization.id
  end
  
  def create
    @procedure = Procedure.new(params[:procedure])
    if @procedure.save
      redirect_to @procedure, :notice => "Successfully created area of practice."
    else
      render :action => 'new'
    end
  end
  
  def edit
    @procedure = Procedure.find(params[:id])
    @specialization = Specialization.find(params[:specialization_id])
    @procedure_ancestry = [["~ No parent ~", nil]] + ancestry_options(@specialization.procedures.arrange(:order => 'name'), @procedure)
  end
  
  def update
    @procedure = Procedure.find(params[:id])
    if @procedure.update_attributes(params[:procedure])
      redirect_to @procedure, :notice  => "Successfully updated area of practice."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @procedure = Procedure.find(params[:id])
    @procedure.destroy
    # redirect_to '/specializations', :notice => "Successfully destroyed scope of practice."
    redirect_to procedures_url, :notice => "Successfully destroyed area of practice."
  end
  
  def ancestry_options(items, skip_item, &block)
    return ancestry_options(items, skip_item){ |i| "#{'-' * i.depth} #{i.name}" } unless block_given?
    
    result = []
    items.map do |item, sub_items|
      next if item == skip_item
      result << [yield(item), item.id]
      #this is a recursive call:
      result += ancestry_options(sub_items, skip_item, &block)
    end
    result
  end
end
