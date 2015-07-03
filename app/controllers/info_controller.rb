class InfoController < ApplicationController
  include ApplicationHelper

  def faq
    authorize! :view, :faq

    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def terms_and_conditions
    authorize! :view, :faq

    render :layout => 'ajax' if request.headers['X-PJAX']
  end
end
