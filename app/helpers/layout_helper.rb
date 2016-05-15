# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def page_title
    if @page_specific_title.present?
      "#{environment_title} | #{@page_specific_title.html_safe}"
    else
      environment_title
    end
  end

  def environment_title
    if Rails.env.development?
      "PW Local"
    elsif ENV['APP_NAME'] == "pathwaysbc"
      "Pathways"
    elsif ENV['APP_NAME'] == "pathwaysbctest"
      "PW Test"
    elsif ENV['APP_NAME'] == "pathwaysbcdev"
      "PW Dev"
    end
  end

  def set_page_specific_title(title)
    @page_specific_title = h(title.to_s)
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
end
