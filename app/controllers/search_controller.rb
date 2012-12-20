class SearchController < ApplicationController
  skip_authorization_check
  skip_before_filter :login_required
  
  def livesearch
    respond_to do |format|
      format.js
    end
  end
end