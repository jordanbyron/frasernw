class FaqCategoriesController < ApplicationController
  def show
    @category = FaqCategory.find params[:id]
    authorize! :show, @category
  end
end
