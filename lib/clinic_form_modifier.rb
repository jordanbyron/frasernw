class ClinicFormModifier < FormModifier
  def cancel_path
    if token_edit?
      root_url
    elsif admin_rereview?
      archived_review_items_path
    else
      clinics_path
    end
  end

  # RESTRICTABLE_FIELDS = [:specializations]
  # # Do we replace the fields identified by 'key' by a generic comment box?
  # def restrict_editing_for?(key)
  # end
end
