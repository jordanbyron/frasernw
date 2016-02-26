class PublicContentItemsController < ApplicationController
  skip_authorization_check

  def edit
    authorize! :update_public_visibility, ScItem
  end

  def update
    authorize! :update_public_visibility, ScItem

    ScItem.
      where("sc_items.id NOT IN (?)", params[:sc_items]).
      update_all(visible_to_public: false)

    ScItem.
      where("sc_items.id IN (?)", params[:sc_items]).
      update_all(visible_to_public: true)

    redirect_to root_path,
      notice: "Successfully updated public content items"
  end
end
