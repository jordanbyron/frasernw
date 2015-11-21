class NewsItemsController < ApplicationController
  load_and_authorize_resource
  # because we want to be able to edit displaying without editing the record
  skip_authorization_check only: [:edit, :update]

  def index
    @division = begin
      if params[:division_id].present?
        Division.find(params[:division_id])
      else
        current_user.divisions.first
      end
    end

    @props = {
      app: {
        currentUser: {
          isSuperAdmin: current_user.super_admin?,
          divisionIds: current_user.divisions.map(&:id)
        },
        divisions: Division.all.inject({}) do |memo, division|
          memo.merge(division.id => {
            name: division.name
          })
        end,
        newsItems: Serialized.generate(:news_items)
      },
      ui: {
        divisionId: @division.id
      }
    }

    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def show
    @news_item = NewsItem.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def new
    @can_edit = true
    @news_item = NewsItem.new
    @divisions = NewsItem.permitted_division_assignments(current_user)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def create
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save && @news_item.display_in_divisions!(divisions_to_assign, current_user)
      create_news_item_activity

      redirect_to front_as_division_path(@news_item.owner_division), :notice  => "Successfully created news item."
    else
      render text: "Unauthorized to assign to that division"
    end
  end

  def edit
    @news_item = NewsItem.find(params[:id])
    @can_edit = current_user.divisions.include?(@news_item.owner_division)
    @divisions = NewsItem.permitted_division_assignments(current_user)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def update
    @news_item = NewsItem.find(params[:id])
    if current_user.divisions.include?(@news_item.owner_division)
      render(action: :edit) unless @news_item.update_attributes(params[:news_item])
    end

    if @news_item.display_in_divisions!(divisions_to_assign, current_user)
      redirect_to front_as_division_path(current_user.divisions.first), :notice  => "Successfully updated news item."
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

  def divisions_to_assign
    params[:news_item][:division_ids].select(&:present?).map{|id| Division.find(id) }
  end

  def create_news_item_activity
    # TODO: #division
    @news_item.create_activity(
      action: :create,
      update_classification_type: Subscription.news_update,
      type_mask: @news_item.type_mask,
      type_mask_description: @news_item.type,
      format_type: 0,
      format_type_description: "Internal",
      parent_id: @news_item.owner_division.id,
      parent_type: "Division",
      owner: @news_item.owner_division
    )
  end
end
