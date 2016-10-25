class ProceduresController < ApplicationController
  load_and_authorize_resource

  def index
    @specialization = Specialization.find(
      params[:specialization_id]
    ) if params[:specialization_id].present?
  end

  def show
    @layout_heartbeat_loader = false
    @procedure = Procedure.find(params[:id])
  end

  def new
    @procedure = Procedure.new

    build_procedure_specializations!(@procedure)
  end

  def create
    @procedure = Procedure.new(params[:procedure])
    if @procedure.save
      Denormalized.regenerate(:procedures)

      redirect_to @procedure,
        notice: "Successfully created area of practice."
    else
      render action: :new
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
    redirect_to procedures_url, notice: "Successfully deleted area of practice."
  end

  private

  def build_procedure_specializations!(procedure)
    Specialization.all.each do |specialization|
      procedure.procedure_specializations.find_or_initialize_by(
        specialization_id: specialization.id
      )
    end
  end
end
