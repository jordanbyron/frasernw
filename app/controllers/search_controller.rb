class SearchController < ApplicationController
  skip_authorization_check
  skip_before_filter :require_authentication

  def livesearch_all_entries
    respond_to do |format|
      format.js
    end
  end

  #global data consistent between all divisions
  def refresh_livesearch_global
    respond_to do |format|
      format.js
    end
  end

  #sitewide specialist and clinic data
  def refresh_livesearch_all_entries
    @specialization = Specialization.find(params[:specialization_id])
    respond_to do |format|
      format.js
    end
  end
end
