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

  def edit
    @faq = Faq.find params[:id]
  end

  def update
    @faq = Faq.find params[:id]
    @faq.update_attributes params[:faq]

    redirect_to @faq.faq_category
  end

  def destroy
    @faq = Faq.find params[:id]

    @faq.destroy

    redirect_to @faq.faq_category
  end
end
