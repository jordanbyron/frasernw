module ButtonHelper

  def delete_button(path, confirmation, mini: false)
    link_to(
      path,
      data: { confirm: confirmation },
      method: :delete,
      class: "btn#{mini ? ' btn-mini' : ''}"
    ) do
        content_tag(:i, "", class: "icon-trash") +
        content_tag(:span, " Delete")
    end
  end
end
