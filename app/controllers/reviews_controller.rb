class ReviewsController < ApplicationController
  load_and_authorize_resource

  def index
    @versions = Version.needs_review.paginate(:page => params[:page], :per_page => 50)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def accept
    review = Review.find(params[:review_id])
    review.accept
    redirect_to reviews_path, :notice => "Successfully accepted changes."
  end

  def destroy
    review = Review.find(params[:id])
    review.reject!
    review.destroy
    redirect_to reviews_path, :notice => "Rejected changes"
  end
end
