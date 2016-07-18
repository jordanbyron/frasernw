class StaticPagesController < UserSessionsController
  include ApplicationHelper

  def terms_and_conditions
    authorize! :terms_and_conditions, :static_pages
  end

  def pathways_info
  end
end
