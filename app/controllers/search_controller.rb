class SearchController < ApplicationController
  skip_authorization_check
  skip_before_filter :login_required
  
  caches_action :livesearch
  
  def livesearch
    respond_to do |format|
      format.js
    end
  end
end