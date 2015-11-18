class NewsItemsController < ApplicationController
  load_and_authorize_resource

  def index
    # TODO
    @owned_news_items = NewsItem.in_divisions(current_user_divisions).paginate(:page => params[:owned_page], :per_page => 30)
    # TODO
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
    # TODO #division
    if current_user_is_admin? && !current_user_divisions.include?(@news_item.owner_division) && !current_user_is_super_admin?
      render :action => 'new', :notice  => "Can't create a news item in that division."
    elsif @news_item.save
      @news_item.display_in_divisions!(@news_item.owner_division)

      redirect_to front_as_division_path(@news_item.owner_division), :notice  => "Successfully created news item."
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
      @news_item.display_in_divisions!(@news_item.owner_division)

      redirect_to front_as_division_path(@news_item.owner_division), :notice  => "Successfully updated news item."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy
    redirect_to news_items_path, :notice => "Successfully deleted news item."
  end

  private

  def create_news_item_activity
    # TODO: #division
    @news_item.create_activity action: :create, update_classification_type: Subscription.news_update, type_mask: @news_item.type_mask, type_mask_description: @news_item.type, format_type: 0, format_type_description: "Internal", parent_id: @news_item.division.id, parent_type: "Division",  owner: @news_item.division
  end
end
