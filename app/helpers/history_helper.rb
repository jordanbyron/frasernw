module HistoryHelper
  def history_icon(item)
    link_to(
      "<i class='icon-folder-open icon-black'></i>".html_safe,
      history_index(item),
      target: "_blank"
    )
  end

  def history_button(item)
    link_to(
      "<i class='icon-folder-open'></i>".html_safe + " History ",
      history_index(item),
      class: "btn btn-mini stacked-button",
      target: "_blank"
    )
  end

  def large_history_button(item)
    link_to(
      "<i class='icon-folder-open'></i>".html_safe + " History",
      history_index(item),
      class: "btn",
      target: "_blank"
    )
  end

  def history_index(item)
    history_path(item_id: item.id, item_type: item.class.to_s)
  end

  def history_verb(node, item, options= {})
    case_adjusted_verb =
      if options[:capitalize]
        node.verb.capitalize
      else
        node.verb
      end

    if node.show_new_version_path?
      link_to case_adjusted_verb, node.new_version_path, target: "_blank"
    elsif options[:bold]
      content_tag :strong, case_adjusted_verb
    else
      case_adjusted_verb
    end
  end

  def review_node_id(node)
    if node.target_klass == ReviewItem && node.has_note?
      node.raw.target.id.to_s
    end
  end
end
