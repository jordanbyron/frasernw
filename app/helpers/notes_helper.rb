module NotesHelper
  def notes_icon(noteable)
    classes = ["icon-tag"]
    classes << "icon-black" unless noteable.notes.any?

    link_to("<i class='#{classes.join(' ')}'></i>".html_safe, notes_index(noteable), target: "_blank")
  end

  def notes_button(noteable)
    link_to("<i class='icon-tag'></i>".html_safe + " Notes " + "(#{noteable.notes.count})" , notes_index(noteable), class: "btn btn-mini stacked-button", target: "_blank")
  end

  def notes_index(noteable)
    notes_path(noteable_id: noteable.id, noteable_type: noteable.class.to_s)
  end
end
