class NewslettersController < ApplicationController
  skip_authorization_check

  def index
    authorize! :index, Newsletter

    @newsletters = Newsletter.ordered
  end

  def new
    authorize! :create, Newsletter

    @newsletter = Newsletter.new
    2.times do
      @newsletter.description_items.new
    end
  end

  def create
    authorize! :create, Newsletter

    @newsletter = Newsletter.create(params[:newsletter])

    redirect_to newsletters_path, notice: "Successfully created newsletter"
  end

  def edit
    authorize! :edit, Newsletter

    @newsletter = Newsletter.find(params[:id])
  end

  def update
    authorize! :update, Newsletter

    @newsletter = Newsletter.find(params[:id])
    @newsletter.update_attributes(params[:newsletter])

    redirect_to newsletters_path, notice: "Successfully updated newsletter"
  end

  def destroy
    authorize! :destroy, Newsletter

    Newsletter.find(params[:id]).destroy

    redirect_to newsletters_path, notice: "Successfully deleted newsletter"
  end
end
