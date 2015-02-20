class SubscriptionsController < ApplicationController
 load_and_authorize_resource

  # GET /subscriptions
  # GET /subscriptions.json
  def index
    @subscriptions = Subscription.all
    @owned_news_items = NewsItem.in_divisions(current_user_divisions).paginate(:page => params[:owned_page], :per_page => 30)
    @other_news_items = NewsItem.in_divisions(Division.all - current_user_divisions).paginate(:page => params[:other_page], :per_page => 30)
    render :layout => 'ajax' if request.headers['X-PJAX']

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: @subscriptions }
    # end
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
    @subscription = Subscription.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subscription }
    end
  end

  # GET /subscriptions/new
  # GET /subscriptions/new.json
  def new
    @user = current_user
    @subscription = Subscription.new(user_id: @user.id)
    #@subscription.subscription_news_item_type.build unless @subscription.subscription_news_item_type.present?
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subscription }
    end
  end

  # GET /subscriptions/1/edit
  def edit
    @subscription = Subscription.find(params[:id])
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(params[:subscription])

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to "index", notice: 'Subscription was successfully created.' }
        format.json { render json: @subscription, status: :created, location: @subscription }
      else
        format.html { render action: "new" }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subscriptions/1
  # PUT /subscriptions/1.json
  def update
    @subscription = Subscription.find(params[:id])

    respond_to do |format|
      if @subscription.update_attributes(params[:subscription])
        format.html { redirect_to "index", notice: 'Subscription was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to subscriptions_url }
      format.json { head :ok }
    end
  end
end
