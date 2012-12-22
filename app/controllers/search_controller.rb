class SearchController < ApplicationController
  skip_authorization_check
  skip_before_filter :login_required
  
  def livesearch
    respond_to do |format|
      format.js
    end
  end
  
  def livesearch_all
    respond_to do |format|
      format.js
    end
  end
  
  def refresh_livesearch_global
    respond_to do |format|
      format.js
    end
  end
  
  def refresh_livesearch_all
    respond_to do |format|
      format.js
    end
  end
  
  def refresh_livesearch_division
    @division = Division.find(params[:division_id])
    respond_to do |format|
      format.js
    end
  end
end