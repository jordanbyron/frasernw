class SearchController < ApplicationController
  skip_authorization_check
  skip_before_filter :login_required

  def livesearch
    respond_to do |format|
      format.js
    end
  end

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

  #divisional specialist and clinic data
  def refresh_livesearch_division_entries
    @division = Division.find(params[:division_id])
    @specialization = Specialization.find(params[:specialization_id])
    respond_to do |format|
      format.js
    end
  end

  #divisional content items, including that shared with the division from other divisions
  def refresh_livesearch_division_content
    @division = Division.find(params[:division_id])
    respond_to do |format|
      format.js
    end
  end
end