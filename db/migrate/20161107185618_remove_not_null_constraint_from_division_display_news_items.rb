class RemoveNotNullConstraintFromDivisionDisplayNewsItems < ActiveRecord::Migration
  def change
    change_column_null(:division_display_news_items, :news_item_id, true)
  end
end
