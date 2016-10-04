class SubscriptionsController < ApplicationController
 load_and_authorize_resource
  def index
    @subscriptions =
      current_user.
        subscriptions.
        includes(:specializations, :divisions, :sc_categories)
    respond_to do |format|
      format.html
      format.json { render json: @subscriptions }
    end
  end

  def show
    @subscription = current_user.subscriptions.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @subscription }
    end
  end

  def new
    @subscription = current_user.subscriptions.new
    respond_to do |format|
      format.html
      format.json { render json: @subscription }
    end
  end

  def edit
    @subscription = current_user.subscriptions.find(params[:id])
  end

  def create
    @subscription = Subscription.new(subscription_params)
    @subscription.user = current_user
    respond_to do |format|
      if @subscription.save
        format.html {
          redirect_to subscriptions_url,
          notice: 'Subscription was successfully created.'
        }
        format.json {
          render json: @subscription,
          status: :created,
          location: @subscription
        }
      else
        format.html {
          render action: "new"
        }
        format.json {
          render json: @subscription.errors,
          status: :unprocessable_entity
        }
      end
    end
  end

  def update
    @subscription = current_user.subscriptions.find(params[:id])
    respond_to do |format|
      if @subscription.update_attributes(subscription_params)
        format.html {
          redirect_to subscriptions_url,
          notice: "Subscription was successfully updated."
        }
        format.json { head :ok }
      else
        format.html {
          render action: "edit",
          notice: "Sorry, there was an error updating your subscription."
        }
        format.json {
          render json: @subscription.errors,
          status: :unprocessable_entity
        }
      end
    end
  end

  def destroy
    @subscription = Subscription.find(params[:id])
    if (@subscription.user == current_user) && @subscription.destroy
      respond_to do |format|
        format.html { redirect_to subscriptions_url }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to subscriptions_url,
          alert: "We had trouble deleting this subscription"
        }
        format.json {
          render json: @subscription.errors,
          status: :unprocessable_entity
        }
      end
    end
  end

  private
  def subscription_params
    if params[:subscription][:sc_category_ids].present?
      params[:subscription][:sc_category_ids].reject!(&:blank?)
    end
    if params[:subscription][:specialization_ids].present?
      params[:subscription][:specialization_ids].reject!(&:blank?)
    end
    if params[:subscription][:news_type].present?
      params[:subscription][:news_type].reject!(&:blank?)
    end
    if params[:subscription][:division_ids].present?
      params[:subscription][:division_ids].reject!(&:blank?)
    end
    if params[:subscription][:sc_item_format_type].present?
      params[:subscription][:sc_item_format_type].reject!(&:blank?)
    end
    if params[:subscription][:target_class] == "ScItem"
      params[:subscription].delete(:news_type)
      params[:subscription][:news_type] = ""
    else params[:subscription][:target_class] == "NewsItem"
      params[:subscription].delete(:sc_category_ids)
      params[:subscription].delete(:specialization_ids)
      params[:subscription].delete(:sc_item_format_type)
      params[:subscription][:sc_category_ids] = ""
      params[:subscription][:specialization_ids] = ""
      params[:subscription][:sc_item_format_type] = ""
    end
    params[:subscription]
  end
end
