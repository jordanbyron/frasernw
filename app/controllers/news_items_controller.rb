class NewsItemsController < ApplicationController
  load_and_authorize_resource
  skip_authorization_check only: [:update_borrowing]
  skip_authorize_resource only: [:update_borrowing]

  def index
    @division = begin
      if params[:division_id].present?
        Division.find(params[:division_id])
      else
        current_user.as_divisions.first
      end
    end

    @init_data = {
      app: {
        newsItems: Denormalized.generate(:news_items)
      },
      ui: {
        persistentConfig: {
          divisionId: @division.id
        }
      }
    }
  end

  def archive
    @divisions =
      if params[:division_id].present?
        [ Division.find(params[:division_id]) ]
      else
        current_user.as_divisions
      end

    @news_items = NewsItem::TYPE_HASH.
      keys.
      except(NewsItem::TYPE_SPECIALIST_CLINIC_UPDATE).
      inject({}) do |memo, key|
        memo.merge(key => NewsItem.type_in_divisions(key, @divisions))
      end
  end

  def show
    @news_item = NewsItem.find(params[:id])
  end

  def new
    @news_item = NewsItem.new
    @divisions = NewsItem.permitted_division_assignments(current_user)
  end

  def create
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save && @news_item.display_in_divisions!(
      divisions_to_assign(params, @news_item),
      current_user
    )
      Subscription::MailImmediateNotifications.call(
        klass_name: "NewsItem",
        id: @news_item.id,
        delay: true
      )

      redirect_to root_path(division_id: @news_item.owner_division.id),
        notice: "Successfully created news item. Please allow a couple minutes"\
          " for the front page to show your changes."
    else
      render :edit
    end
  end

  def edit
    @news_item = NewsItem.find(params[:id])
    @divisions = NewsItem.permitted_division_assignments(current_user)
  end

  def update
    @news_item = NewsItem.find(params[:id])
    if (
      @news_item.update_attributes(params[:news_item]) &&
        @news_item.display_in_divisions!(
          divisions_to_assign(params, @news_item),
          current_user
        )
    )
      redirect_to root_path(division_id: current_user.as_divisions.first.id),
        notice: "Successfully updated news item. Please allow a couple minutes"\
          " for the front page to show your changes."
    else
      render action: 'edit'
    end
  end

  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy
    redirect_to news_items_path, notice: "Successfully deleted news item."
  end

  def update_borrowing
    @news_item = NewsItem.find(params[:id])
    @division = Division.find(params[:division_id])

    if (
      params[:borrow] == "false" &&
        @news_item.user_can_unborrow?(current_user, @division)
      )
      @news_item.unborrow_from(@division)

      redirect_to news_item_path(@news_item),
        notice: "Successfully stopped borrowing news item for "\
          "#{@division.name}."
    else
      redirect_to news_item_path(@news_item),
        notice: "Unauthorized"
    end
  end

  def copy
    @division = Division.find(params[:target_division_id])
    if @news_item.copy_to(@division, current_user)
      redirect_to news_items_path(division_id: @division.id),
        notice: "Successfully copied '#{@news_item.label}' to "\
          "#{@division.name}."
    else
      redirect_to news_items_path(division_id: @division.id),
        notice: "Unauthorized"
    end
  end

  private

  def divisions_to_assign(params, news_item)
    if params[:news_item][:division_ids]
      params[:news_item][:division_ids].select(&:present?).map do |id|
        Division.find(id)
      end
    else
      [ news_item.owner_division ]
    end
  end
end
