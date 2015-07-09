module ReviewItemsHelper
  def review_path(review_item)
    send(
      "review_#{review_item.item.class.name.underscore}_path",
      review_item.item
    )
  end

  def rereview_path(review_item)
    send(
      "rereview_#{review_item.item.class.name.underscore}_path",
      review_item.item
    )
  end
end
