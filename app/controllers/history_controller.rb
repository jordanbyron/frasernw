class HistoryController < ApplicationController
  def index
    item_klass     = params[:item_type].constantize
    @item          = item_klass.find params[:item_id]

    authorize! :view_history, @item
    if @item.is_a? Noteable
      @new_note      = @item.notes.build
    end
  end
end
