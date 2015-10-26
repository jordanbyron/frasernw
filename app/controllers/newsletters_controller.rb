class NewslettersController < ApplicationController
  skip_authorization_check

  def index
    @newsletters = Newsletter.order(:month_key).all
  end

  def new
    authorize! :create, Newsletter

    @newsletter = Newsletter.new
    2.times do
      @newsletter.description_items.new
    end
  end

  def create
    @newsletter = Newsletter.create(params[:newsletter])

    redirect_to newsletters_path, notice: "Successfully created newsletter"
  end

  def edit
  end

  def destroy
  end
end
