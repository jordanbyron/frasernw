class ScCategoriesController < ApplicationController
  include ScCategoriesHelper
  load_and_authorize_resource

  def index
    @sc_categories = ScCategory.all
  end

  def show
    @sc_category = ScCategory.find(params[:id])
  end

  def new
    @sc_category = ScCategory.new
    @hierarchy =
      sc_category_ancestry_options(ScCategory.unscoped.arrange(order: 'name'), nil)
  end

  def create
    @sc_category = ScCategory.new(params[:sc_category])
    if @sc_category.save
      redirect_to @sc_category, notice: "Successfully created content category."
    else
      render action: 'new'
    end
  end

  def edit
    @sc_category = ScCategory.find(params[:id])
    @hierarchy = sc_category_ancestry_options(
      ScCategory.unscoped.arrange(order: 'name'),
      @sc_category.subtree
    )
  end

  def update
    @sc_category = ScCategory.find(params[:id])
    if @sc_category.update_attributes(params[:sc_category])
      redirect_to @sc_category, notice: "Successfully updated content category."
    else
      render action: 'edit'
    end
  end

  def destroy
    @sc_category = ScCategory.find(params[:id])
    @sc_category.destroy
    redirect_to sc_categories_url, notice: "Successfully deleted content category."
  end
end
