class FrontController < ApplicationController
  load_and_authorize_resource
  include ApplicationHelper
  
  def index
    @front = Front.first
    @front = Front.create if @front.blank?
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def edit
    @front = Front.first
    @front = Front.create if @front.blank?
    ScCategory.all.each do |category|
      featuredContent = FeaturedContent.find_all_by_sc_category_id(category.id)
      featuredContentCount = featuredContent.blank? ? 0 : featuredContent.length
      for x in (featuredContentCount+1)..3
        FeaturedContent.create( :front => @front, :sc_category => category )
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