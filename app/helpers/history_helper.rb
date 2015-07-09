module HistoryHelper
  def history_icon(item)
    link_to("<i class='icon-folder-open icon-black'></i>".html_safe, history_index(item), target: "_blank")
  end

  def history_button(item)
    link_to("<i class='icon-folder-open'></i>".html_safe + " History ", history_index(item), class: "btn btn-mini stacked-button", target: "_blank")
  end

  def large_history_button(item)
    link_to("<i class='icon-folder-open'></i>".html_safe + " History", history_index(item), class: "btn", target: "_blank")
  end

  def history_index(item)
    history_path(item_id: item.id, item_type: item.class.to_s)
  end

  def history_verb(node, item, options= {})
    if node.show_new_version_path?
      link_to node.verb, node.new_version_path, target: "_blank"
    elsif options[:bold]
      content_tag :strong, node.verb
    else
      node.verb
    end
  end
end
