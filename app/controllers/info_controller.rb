class InfoController < ApplicationController
  include ApplicationHelper

  def faq
    @category = FaqCategory.where(name: "Help").first

    authorize! :view, :faq
  end

  def terms_and_conditions
    authorize! :view, :terms_and_conditions
  end

  def privacy_faq
    authorize! :view, :privacy_faq
  end


end
