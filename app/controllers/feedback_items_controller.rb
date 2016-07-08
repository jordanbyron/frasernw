class FeedbackItemsController < ApplicationController
  load_and_authorize_resource

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
      @owned_counts[type] = @feedback_item_types[type].count do |item|
        item.owners.include?(current_user)
      end
    end
  end

  def show
    @feedback_item = FeedbackItem.find(params[:id])
  end

  def create
    @feedback_item = FeedbackItem.create(params[:feedback_item].merge(
      user: current_user
    ))

    if @feedback_item.general?
      FeedbackMailer.general(@feedback_item).deliver
    else
      FeedbackMailer.targeted(@feedback_item).deliver
    end

    render nothing: true, status: 200
  end

  def destroy
    @feedback_item = FeedbackItem.find(params[:id])
    @feedback_item.update_attributes(
      archived: true,
      archiving_division_ids: current_user.divisions
    )
    redirect_to feedback_items_url,
      notice: "Successfully archived feedback item."
  end
end
