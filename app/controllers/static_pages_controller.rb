class StaticPagesController < ApplicationController
  skip_before_filter :require_authentication
  skip_authorization_check

  def contact
    @feedback_item = FeedbackItem.new
    render :contact
  end

  def pathways_info
  end

  def terms_and_conditions
    authorize! :terms_and_conditions, :static_pages
  end

  private

  def omit_contact_modal
    true
  end
end
