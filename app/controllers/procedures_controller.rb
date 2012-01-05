class ProceduresController < ApplicationController
  load_and_authorize_resource
  
  def index
  end
  
  def show
    @procedure = Procedure.find(params[:id])
    if request.headers['X-PJAX']
      render :layout => false
    end
  end
  
  def new
    Specialization.all.each { |specialization| ProcedureSpecialization.find_or_create_by_procedure_id_and_specialization_id(params[:id], specialization.id) }
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
    Specialization.all.each { |specialization| ProcedureSpecialization.find_or_create_by_procedure_id_and_specialization_id(params[:id], specialization.id) }
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
    redirect_to procedures_url, :notice => "Successfully destroyed area of practice."
  end
end
