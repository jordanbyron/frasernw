class FrontController < ApplicationController
  load_and_authorize_resource
  include ApplicationHelper
  
  def index
    @front = Front.first
    @front = Front.create if @front.blank?
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def faq
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def edit
    @front = Front.first
    @front = Front.create if @front.blank?
    ScCategory.all.each do |category|
      featured_content = FeaturedContent.find_all_by_sc_category_id(category.id)
      if category.show_on_front_page?
        #show on front page; make any slots we don't have
        featured_content_count = featured_content.blank? ? 0 : featured_content.length
        for x in (featured_content_count+1)..3
          FeaturedContent.create( :front => @front, :sc_category => category )
        end
      else
        #shouldn't be shown on front page any more
        featured_content.each do |fc|
          FeaturedContent.delete(fc)
        end
      end
    end
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @front = Front.first
    if @front.update_attributes(params[:front])
      redirect_to root_url, :notice  => "Successfully updated front page."
    else
      render :action => 'edit'
    end
  end
end