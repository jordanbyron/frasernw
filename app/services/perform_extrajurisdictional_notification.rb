class PerformExtrajurisdictionalNotification < ServiceObject
  attribute :version, Version

  def call
    return if !(version.item_type == "Address") ||
      !["create", "update"].include?(version.event) ||
      !editor.known? ||
      address_divisions.none? ||
      address.locations.none? ||
      !version.changeset.has_key?("city_id") ||
      !locatable.present? ||
      !(locatable.is_a?(ClinicLocation) || locatable.is_a?(Office))

    if (editor.divisions & address_divisions).none? && !editor.super_admin?
      address_divisions.map(&:admins).uniq.flatten.each do |owner|
        CourtesyMailer.extrajurisdictional_edit_update(
          owner.id,
          (owner.divisions & divisions).first.id,
          editor.id,
          linked_entity.klass.to_s,
          linked_entity.id
        ).deliver
      end
    end
  end

  private

  def linked_entity
    if locatable.is_a?(Office)
      locatable
    else
      locatable.clinic
    end
  end

  def locatable
    address.locations.first.locatable
  end

  def address_divisions
    address.city.present? : address.city.divisions : []
  end

  def address
    version.item
  end

  def editor
    version.safe_editor
  end
end
