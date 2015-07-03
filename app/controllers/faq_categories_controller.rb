class FaqCategoriesController < ApplicationController
  def show
    @category = FaqCategory.find params[:id]
    authorize! :show, @category
  end

  def update_ordering
    @category = FaqCategory.find params[:id]
    authorize! :update_ordering, @category

    params[:faq].each_with_index do |id, index|
      Faq.update_all({index: index + 1}, {id: id})
    end

    render nothing: true
  end
end
