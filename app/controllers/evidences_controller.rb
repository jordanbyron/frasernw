class EvidencesController < ApplicationController
  load_and_authorize_resource

  def index
    @evidences = Evidence.all

    respond_to do |format|
      format.html
      format.json { render json: @evidences }
    end
  end

  def show
    @evidence = Evidence.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @evidence }
    end
  end

  def new
    @evidence = Evidence.new

    respond_to do |format|
      format.html
      format.json { render json: @evidence }
    end
  end

  def edit
    @evidence = Evidence.find(params[:id])
  end

  def create
    @evidence = Evidence.new(params[:evidence])

    respond_to do |format|
      if @evidence.save
        format.html { redirect_to @evidence, notice: 'Evidence was successfully created.' }
        format.json { render json: @evidence, status: :created, location: @evidence }
      else
        format.html { render action: "new" }
        format.json { render json: @evidence.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @evidence = Evidence.find(params[:id])

    respond_to do |format|
      if @evidence.update_attributes(params[:evidence])
        format.html { redirect_to @evidence, notice: 'Evidence was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @evidence.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @evidence = Evidence.find(params[:id])
    @evidence.destroy

    respond_to do |format|
      format.html { redirect_to evidences_url }
      format.json { head :no_content }
    end
  end
end
