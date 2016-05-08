class ProceduresController < ApplicationController
  load_and_authorize_resource except: [:create]
  skip_authorization_check only: [:create]

  def index
    @specialization = Specialization.find(params[:specialization_id]) if params[:specialization_id].present?
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @layout_heartbeat_loader = false
    @procedure = Procedure.find(params[:id])
    @init_data = {
      app: FilterTableAppState.exec(current_user: current_user),
      ui: {
        pageType: "procedure",
        procedureId: @procedure.id,
        hasBeenInitialized: false
      }
    }
  end

  def new
    @procedure = Procedure.new(params[:id])
    Specialization.all.each { |specialization| ProcedureSpecialization.find_or_create_by_procedure_id_and_specialization_id(params[:id], specialization.id) }
    @specializations = [Specialization.find(params[:specialization_id])]
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    params[:procedure]["all_procedure_specializations_attributes"].values.each do |hsh|
      hsh["procedure_id"] = nil if hsh["procedure_id"] == ""
    end
    binding.pry
    @procedure = Procedure.new(params[:procedure])
    if @procedure.save
      redirect_to @procedure, :notice => "Successfully created area of practice."
    else
      render :action => 'new'
    end
  end

  def edit
    @procedure = Procedure.find(params[:id])
    @specializations = @procedure.specializations
    Specialization.all.each { |specialization| ProcedureSpecialization.find_or_create_by_procedure_id_and_specialization_id(params[:id], specialization.id) }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @procedure = Procedure.find(params[:id])
    ExpireFragment.call procedure_path(@procedure)
    params[:procedure][:all_procedure_specializations_attributes].each{ |so_key, so_value|
      so_value[:mapped] = 0 if so_value[:mapped].blank?
      so_value[:specialist_wait_time] = 0 if so_value[:specialist_wait_time].blank?
      so_value[:clinic_wait_time] = 0 if so_value[:clinic_wait_time].blank?
    }

    if @procedure.update_attributes(params[:procedure])
      Denormalized.delay.regenerate(:procedures)
      redirect_to @procedure, :notice  => "Successfully updated area of practice."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @procedure = Procedure.find(params[:id])
    ExpireFragment.call procedure_path(@procedure)
    @procedure.destroy
    redirect_to procedures_url, :notice => "Successfully deleted area of practice."
  end
end
