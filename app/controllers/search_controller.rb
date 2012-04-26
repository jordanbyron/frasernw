class SearchController < ApplicationController
  skip_authorization_check
  
  caches_action :livesearch
  
  def livesearch
    respond_to do |format|
      format.js
    end
  end
end