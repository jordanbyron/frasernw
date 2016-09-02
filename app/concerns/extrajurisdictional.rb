module Extrajurisdictional
  extend ActiveSupport::Concern

  included do
    after_commit :notify_owning_division
  end

  def notify_owning_division
    if extrajurisdictional_owners && !editor(self).super_admin?
      extrajurisdictional_owners.flatten.uniq.each do |owner|
        SubscriptionMailer.extrajurisdictional_edit_update(
          (owner.divisions & target_divisions).first.id,
          owner.id,
          editor(self).id,
          location_source_record_class,
          location_source_record_id
        ).deliver
      end
    end
  end

  private

  def target_divisions
    if (
      city.present? &&
        city.divisions.any? &&
        ![city.divisions].include?(editor(self).divisions)
      )
      city.divisions
    end
  end

  def extrajurisdictional_owners
    if target_divisions
      target_divisions.each.map do |division|
        User.admin.active.select{ |user| user.divisions.include? division }
      end
    end
  end

  def editor(location)
    User.find(location.versions.last.whodunnit)
  end

  def location_source_record_class
    if locatable_type == "ClinicLocation"
      "Clinic"
    elsif locatable_type == "Office"
      "Specialist"
    end
  end

  def location_source_record_id
    if locatable_type == "ClinicLocation"
      locatable.clinic_id
    elsif locatable_type == "Office"
      locatable.specialists.last.id
    end
  end

end
