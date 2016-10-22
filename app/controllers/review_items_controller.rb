class ReviewItemsController < ApplicationController
  load_and_authorize_resource

  def index
    @review_items = ReviewItem.active
  end

  def archived
    @review_items =
      ReviewItem.archived.order('id desc').paginate(page: params[:page], per_page: 30)
  end
end
