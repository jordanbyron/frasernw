class ScItemsController < ApplicationController
  include ScCategoriesHelper
  load_and_authorize_resource
  before_filter :authorize_division_for_user, only: :index

  def index
    @division = Division.find(params[:id])
  end

  def show
    @sc_item = ScItem.find(params[:id])
    @division = current_user.as_divisions.first
    @borrow_url = borrow_sc_item_path(@sc_item)
  end

  def new
    @sc_item = ScItem.new
  end

  def create
    @sc_item = ScItem.new(params[:sc_item])
    if @sc_item.save
      Subscription::MailImmediateNotifications.call(
        klass_name: "ScItem",
        id: @sc_item.id,
        delay: true
      )
      FulfillDivisionalScItemSubscriptions.call(sc_item: @sc_item)
      redirect_to sc_item_path(@sc_item),
        notice: "Successfully created content item."
    else
      render action: 'new'
    end
  end

  def edit
    @sc_item = ScItem.find(params[:id])
  end

  def update
    @sc_item = ScItem.find(params[:id])
    if @sc_item.update_attributes(params[:sc_item])
      redirect_to @sc_item, notice: "Successfully updated content item."
    else
      render action: 'edit'
    end
  end

  def destroy
    @sc_item = ScItem.find(params[:id])
    redirect_division = @sc_item.division
    @sc_item.destroy
    redirect_to division_content_items_path(redirect_division),
      notice: "Successfully deleted content item."
  end

  def borrow
    @sc_item = ScItem.find(params[:id])
    authorize! :borrow, @sc_item
    @division = Division.find(params[:division_id])

    success = params[:is_borrowed].present? &&
      @sc_item.present? &&
      @division.present? &&
      can?(:borrow, @sc_item) &&
      UpdateScItemBorrowing.call(
        division_id: @division.id,
        sc_item: @sc_item,
        is_borrowed: params[:is_borrowed].to_b
      )

    notice = begin
      if success
        if params[:is_borrowed].to_b
          "Now displaying this item in #{@division.name}"
        else
          "No longer displaying this item in #{@division.name}"
        end
      else
        "Unable to complete your request"
      end
    end

    redirect_to sc_item_path(@sc_item), notice: notice
  end

  def bulk_borrow
    @sc_items = ScItem.find(params[:item_ids])
    authorize! :bulk_borrow, ScItem
    @division = Division.find(params[:division_id])

    successful_items = @sc_items.select do |sc_item|
      can?(:update, sc_item) &&
      UpdateScItemBorrowing.call(
        division_id: @division.id,
        sc_item: sc_item,
        is_borrowed: true
      )
    end

    notice = "Now displaying #{successful_items.map(&:title).to_sentence} " +
      "in #{@division.name}."
    redirect_to borrowable_content_items_path(@division), notice: notice
  end

  private

  def authorize_division_for_user
    if !(
      current_user.as_super_admin? ||
        (current_user.as_divisions.include? Division.find(params[:id]))
    )
      redirect_to root_url, notice: "You are not allowed to access this page"
    end
  end
end
