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
    @procedure = Procedure.new

    build_procedure_specializations!(@procedure)

    @procedure.
      all_procedure_specializations.
      find do |procedure_specialization|
        procedure_specialization.specialization_id == params[:specialization_id].to_i
      end.mapped = true
  end

  def create
    @procedure = Procedure.new(params[:procedure])
    if @procedure.save
      Denormalized.regenerate(:procedures)
      
      redirect_to @procedure, :notice => "Successfully created area of practice."
    else
      render :action => 'new'
    end
  end

  def edit
    @procedure = Procedure.find(params[:id])

    build_procedure_specializations!(@procedure)
  end

  def update
    @procedure = Procedure.find(params[:id])
    ExpireFragment.call procedure_path(@procedure)

    if @procedure.update_attributes(params[:procedure])
      Denormalized.regenerate(:procedures)

      redirect_to(@procedure, notice: "Successfully updated area of practice.")
    else
      render :edit
    end
  end

  def destroy
    @procedure = Procedure.find(params[:id])
    ExpireFragment.call procedure_path(@procedure)
    @procedure.destroy
    redirect_to procedures_url, :notice => "Successfully deleted area of practice."
  end

  private

  def build_procedure_specializations!(procedure)
    Specialization.all.each do |specialization|
      existing_procedure_specialization = procedure.
        all_procedure_specializations.where(
          specialization_id: specialization.id
        ).first

      if existing_procedure_specialization.nil?
        procedure.all_procedure_specializations.build(
          specialization_id: specialization.id
        )
      end
    end
  end
end
