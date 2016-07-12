class FeedbackItemsController < ApplicationController
  load_and_authorize_resource
  skip_before_filter :require_authentication, only: [:create]

  def index
    @feedback_item_types = {}
    @owned_counts = {}

    [
      :specialist,
      :clinic,
      :content,
      :general
    ].each do |type|
      @feedback_item_types[type] = FeedbackItem.active.send(type)
      @owned_counts[type] = @feedback_item_types[type].to_a.count do |item|
        item.owners.include?(current_user)
      end
    end
  end

  def show
    @feedback_item = FeedbackItem.find(params[:id])
  end

  def create
    if current_user.authenticated?
      @feedback_item = FeedbackItem.new(params[:feedback_item].merge(
        user: current_user
      ))
    else
      @feedback_item = FeedbackItem.new(params[:feedback_item])
    end

    if ((@feedback_item.general? && @feedback_item.user.nil?) ||
      current_user.authenticated?)

      @feedback_item.save

      if @feedback_item.general?
        FeedbackMailer.general(@feedback_item).deliver
      else
        FeedbackMailer.targeted(@feedback_item).deliver
      end

      render nothing: true, status: 200
    else
      render nothing: true, status: 500
    end
  end

  def destroy
    @feedback_item = FeedbackItem.find(params[:id])
    @feedback_item.update_attributes(
      archived: true,
      archiving_division_ids: current_user.divisions.map(&:id)
    )
    redirect_to feedback_items_url,
      notice: "Successfully archived feedback item."
  end
end
