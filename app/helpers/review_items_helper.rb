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
      review_item.item,
      review_item_id: review_item.id
    )
  end

  def review_warning(review_item)
    return "" unless review_item.present?

    content_tag(
      :div,
      "You are reviewing changes made by #{@review_item.safe_user.name} on #{@review_item.created_at.to_s(:date_ordinal)}.  All changes made by the user have been highlighted in orange.",
      class: "alert alert-info"
    )
  end

  def rereview_warning(review_item)
    return "" unless review_item.present?

    content_tag(
      :div,
      "You are rereviewing changes made by #{@review_item.safe_user.name} on #{@review_item.created_at.to_s(:date_ordinal)}.  The base state of the form is as the user would have seen it before making the changes.  All changes made by the user have been highlighted in orange.",
      class: "alert alert-info"
    )
  end
end
