class ClinicFormModifier
  include Rails.application.routes.url_helpers

  def method
    case interaction_type
    when :new then :post
    else :put
    end
  end

  def form_action
    if interaction_type == :new
      :create
    elsif interaction_type == :review
      :accept
    elsif secret_edit?
      :update
    elsif bot_edit?
      :temp_update
    else
      :update
    end
  end

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
