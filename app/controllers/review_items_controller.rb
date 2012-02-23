class ReviewItemsController < ApplicationController
  # GET /review_items
  # GET /review_items.json
  def index
    @review_items = ReviewItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @review_items }
    end
  end

  # GET /review_items/1
  # GET /review_items/1.json
  def show
    @review_item = ReviewItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @review_item }
    end
  end

  # GET /review_items/new
  # GET /review_items/new.json
  def new
    @review_item = ReviewItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @review_item }
    end
  end

  # GET /review_items/1/edit
  def edit
    @review_item = ReviewItem.find(params[:id])
  end

  # POST /review_items
  # POST /review_items.json
  def create
    @review_item = ReviewItem.new(params[:review_item])

    respond_to do |format|
      if @review_item.save
        format.html { redirect_to @review_item, notice: 'Review item was successfully created.' }
        format.json { render json: @review_item, status: :created, location: @review_item }
      else
        format.html { render action: "new" }
        format.json { render json: @review_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /review_items/1
  # PUT /review_items/1.json
  def update
    @review_item = ReviewItem.find(params[:id])

    respond_to do |format|
      if @review_item.update_attributes(params[:review_item])
        format.html { redirect_to @review_item, notice: 'Review item was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @review_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /review_items/1
  # DELETE /review_items/1.json
  def destroy
    @review_item = ReviewItem.find(params[:id])
    @review_item.destroy

    respond_to do |format|
      format.html { redirect_to review_items_url }
      format.json { head :ok }
    end
  end
end
