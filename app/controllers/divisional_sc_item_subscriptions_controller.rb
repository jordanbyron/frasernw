class DivisionalScItemSubscriptionsController < ApplicationController
  load_and_authorize_resource

  def borrow_existing
    subscription = DivisionalScItemSubscription.find(params[:id])

    subscription.borrow_existing!

    redirect_to division_path(subscription.division),
      notice: "Borrowed all the items that match your subscription criteria."
  end
end
