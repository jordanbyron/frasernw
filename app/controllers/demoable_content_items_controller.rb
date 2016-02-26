class DemoableContentItemsController < ApplicationController
  skip_authorization_check

  def edit
    authorize! :update_demoable, ScItem
  end

  def update
    authorize! :update_demoable, ScItem

    ScItem.
      where("sc_items.id NOT IN (?)", params[:sc_items]).
      update_all(demoable: false)

    ScItem.
      where("sc_items.id IN (?)", params[:sc_items]).
      update_all(demoable: true)

    redirect_to root_path,
      notice: "Successfully updated public content items"
  end
end
