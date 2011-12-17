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
    @procedure_ancestry = [["~ No parent ~", nil]] + ancestry_options_limited(@specialization.procedures.arrange(:order => 'name'), nil)
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
    @procedure_ancestry = [["~ No parent ~", nil]] + ancestry_options_limited(@specialization.procedures.arrange(:order => 'name'), @procedure.subtree)
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
  
  def ancestry_options_limited(items, skip_tree, &block)
    return ancestry_options_limited(items, skip_tree){ |i| "#{'-' * i.depth} #{i.name}" } unless block_given?
    
    result = []
    items.map do |item, sub_items|
      next if skip_tree and skip_tree.include? item
      result << [yield(item), item.id]
      result += ancestry_options_limited(sub_items, skip_tree, &block)
    end
    result
  end
end
