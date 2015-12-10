class SearchController < ApplicationController
  skip_authorization_check
  skip_before_filter :login_required

  def livesearch_all_entries
    respond_to do |format|
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

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
