class ReviewItemsController < ApplicationController
  load_and_authorize_resource

  def index
    @review_items = ReviewItem.active
  end

  def archived
    @review_items =
      ReviewItem.archived.order('id desc').paginate(page: params[:page], per_page: 30)
  end

  def destroy
    # temporary logging to find where this is getting called
    begin
      $redis.lpush("referers_destroying_review_items", request.referer)
    rescue
    end

    @review_item = ReviewItem.find(params[:id])
    @review_item.destroy
    redirect_to review_items_url, notice: "Successfully discarded changes."
  end
end
