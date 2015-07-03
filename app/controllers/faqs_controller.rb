class FaqsController < ApplicationController
  authorize_resource

  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(params[:faq])
    @faq.index = @faq.faq_category.next_available_index

    @faq.save

    redirect_to @faq.faq_category
  end
end
