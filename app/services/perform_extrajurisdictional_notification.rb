class PerformExtrajurisdictionalNotification < ServiceObject
  attribute :version_id, Integer

  def call
    return if !["create", "update"].include?(version.event) ||
      !relevant_fields_changed? ||
      !editor.known? ||
      !location.present? ||
      location.divisions.none? ||
      !locatable.present? ||
      !(locatable.is_a?(ClinicLocation) || locatable.is_a?(Office))

    if (editor.as_divisions & location.divisions).none? && !editor.as_super_admin?
      location.divisions.map(&:admins).uniq.flatten.each do |owner|
        CourtesyMailer.extrajurisdictional_edit_update(
          owner.id,
          (owner.divisions & location.divisions).first.id,
          editor.id,
          linked_entity.class.to_s,
          linked_entity.id
        ).deliver
      end
    end
  end

  private

  def relevant_fields_changed?
    (version.item_type == "Address" &&
      version.changeset.has_key?("city_id")) ||
      (version.item_type == "Location" &&
        (version.changeset.has_key?("hospital_in_id") &&
          version.changeset["hospital_in_id"][1].present?) ||
        (version.changeset.has_key?("location_in_id") &&
          version.changeset["location_in_id"][1].present?))
  end

  def location
    if version.item_type == "Address"
      version.item.locations.first
    else
      version.item
    end
  end

  def linked_entity
    if locatable.is_a?(Office)
      locatable
    else
      locatable.clinic
    end
  end

  def locatable
    location.locatable
  end

  def editor
    version.safe_user
  end

  def version
    @version ||= Version.find(version_id)
  end
end
