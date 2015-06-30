class HistoryController < ApplicationController
  def index
    authorize! :index, :history

    item_klass     = params[:item_type].constantize
    @item          = item_klass.find params[:item_id]
    @new_note      = @item.notes.build
    @notes         = @item.persisted_notes
  end
end
