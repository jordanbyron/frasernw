class SearchController < ApplicationController
  skip_authorization_check

  def livesearch
    respond_to do |format|
      format.js
    end
  end

end