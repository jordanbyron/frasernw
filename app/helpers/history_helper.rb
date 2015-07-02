module HistoryHelper
  def history_icon(item)
    classes = ["icon-tag"]
    classes << "icon-black" unless noteable.history.any?

    link_to("<i class='#{classes.join(' ')}'></i>".html_safe, history_index(item), target: "_blank")
  end

  def history_button(item)
    link_to("<i class='icon-tag'></i>".html_safe + " History ", history_index(item), class: "btn btn-mini stacked-button", target: "_blank")
  end

  def history_index(item)
    history_path(item_id: item.id, item_type: item.class.to_s)
  end
end
