class NewsItemsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @owned_news_items = NewsItem.in_divisions(current_user_divisions).paginate(:page => params[:owned_page], :per_page => 30)
    @other_news_items = NewsItem.in_divisions(Division.all - current_user_divisions).paginate(:page => params[:other_page], :per_page => 30)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @news_item = NewsItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @news_item = NewsItem.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @news_item = NewsItem.new(params[:news_item])
    if current_user_is_admin? && !current_user_divisions.include?(@news_item.division)
      render :action => 'new', :notice  => "Can't create a news item in that division."
    elsif @news_item.save
      division = @news_item.division
      @news_item.create_activity :create, owner: division
      #expire all the front-page news content for users that are in the divisions that we just updated
      User.in_divisions([division]).map{ |u| u.divisions.map{ |d| d.id } }.uniq.each do |division_group|
        expire_fragment "latest_updates_#{division_group.join('_')}"
      end
      
      redirect_to front_as_division_path(division), :notice  => "Successfully created news item."
    else
      render :action => 'new'
    end
  end
  
  def edit
    @news_item = NewsItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @news_item = NewsItem.find(params[:id])
    if @news_item.update_attributes(params[:news_item])
      
      division = @news_item.division
      
      #expire all the front-page news content for users that are in the divisions that we just updated
      User.in_divisions([division]).map{ |u| u.divisions.map{ |d| d.id } }.uniq.each do |division_group|
        expire_fragment "latest_updates_#{division_group.join('_')}"
      end
      
      redirect_to front_as_division_path(division), :notice  => "Successfully updated news item."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy
    redirect_to news_items_path, :notice => "Successfully deleted news item."
  end
end
