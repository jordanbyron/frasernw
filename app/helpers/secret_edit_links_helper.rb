module SecretEditLinksHelper
  def secret_edit_links(profile)
    react_component(
      "SecretEditLinks",
      {
        addLink: secret_tokens_path,
        accessibleId: profile.id,
        accessibleType: profile.class.to_s,
        currentUserName: current_user.name,
        links: profile.valid_secret_edit_links(current_user),
        canEdit: can?(:edit, profile),
        modal: { isVisible: false }
      },
      { class: "collapse", id: "share" }
    )
  end
end
