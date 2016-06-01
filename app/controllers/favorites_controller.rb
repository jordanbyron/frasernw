class FavoritesController < ApplicationController
  include ApplicationHelper

  skip_authorization_check

  def edit
    klass = params[:model].singularize.camelize.constantize
    item = klass.find params[:id]

    f = Favorite.find_by(
      user_id: current_user.id,
      favoritable_id: params[:id],
      favoritable_type: klass
    )

    if f.present?
      f.destroy
      @favorited = false
    else
      f = Favorite.new
      f.user = current_user
      f.favoritable = item
      f.save
      @favorited = true
    end

    respond_to do |format|
      format.json { render json: @favorited }
    end
  end

end
