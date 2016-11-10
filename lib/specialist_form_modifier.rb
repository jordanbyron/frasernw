class SpecialistFormModifier < FormModifier
  ROUTES = Rails.application.routes.url_helpers

  def cancel_path
    if token_edit?
      ROUTES.root_url
    elsif admin_rereview?
      ROUTES.archived_review_items_path
    else
      ROUTES.root_path
    end
  end

  # RESTRICTABLE_FIELDS = [:specializations]
  # # Do we replace the fields identified by 'key' by a generic comment box?
  # def restrict_editing_for?(key)
  # end

end
