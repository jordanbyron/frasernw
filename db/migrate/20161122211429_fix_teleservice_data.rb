class FixTeleserviceData < ActiveRecord::Migration
  def change
    add_column :specialists,
      :teleservices_require_review,
      :boolean,
      default: false
    add_column :clinics,
      :teleservices_require_review,
      :boolean,
      default: false

    Teleservice.all.reject do |teleservice|
      teleservice.telephone.present? ||
        teleservice.video.present? ||
        teleservice.email.present? ||
        teleservice.store.present? ||
        teleservice.contact_note.present? ||
        # if there could have been data there at some point, and there may
        # be multiple provider matches, it needs review
        teleservice.updated_at != teleservice.created_at
    end.each(&:destroy)

    Teleservice.all.each do |teleservice|
      associated = find_associated(teleservice)

      if !associated.nil?
        teleservice.update_attributes(
          teleservice_provider_type: associated.class.to_s
        )
      end
    end

    [ Specialist, Clinic].each do |klass|
      klass.all.each do |record|
        if record.teleservices.count > 4
          puts "More than 4 teleservices for #{klass} #{record.id}"
        end

        if record.
          teleservices.
          count_by(&:service_type_key).
          values.
          any?{|count| count > 1 }

          puts "More than one teleservice of a given type for  #{klass} #{record.id}"
        end
      end
    end
  end

  def find_associated(teleservice)
    specialist = Specialist.find_by(id: teleservice.teleservice_provider_id)
    clinic = Clinic.find_by(id: teleservice.teleservice_provider_id)

    matches_id = [ specialist, clinic].reject(&:nil?)

    if matches_id.one?
      return matches_id[0]
    elsif matches_id.none?
      puts "No matching ids @ #{teleservice.id}"
    end

    # where there are multiple ID matches a manual review will be necessary
    matches_id.each do |match|
      match.update_attributes(teleservices_require_review: true)
    end

    matches_timestamp_exactly = matches_id.select do |record|
      record.updated_at == teleservice.updated_at
    end

    if matches_timestamp_exactly.one?
      return matches_timestamp_exactly[0]
    elsif matches_timestamp_exactly.length == 2
      puts "Ambiguous absolute matches @ #{teleservice.id}!"
    end

    matches_timestamp_approximately = matches_id.select do |record|
      (record.updated_at - teleservice.updated_at).abs < 5.seconds
    end

    if matches_timestamp_approximately.one?
      return matches_timestamp_approximately[0]
    elsif matches_timestamp_approximately.length == 2
      puts "Ambiguous approximate matches @ #{teleservice.id}!"
    end

    matches_association_timestamps = matches_id.select do |record|
      if record.is_a?(Specialist)
        associations = record.specialist_specializations +
          record.capacities +
          record.privileges +
          record.attendances +
          record.specialist_speaks +
          record.specialist_offices +
          record.versions +
          record.review_items
      else
        associations = record.clinic_specializations +
          record.focuses +
          record.clinic_speaks +
          record.clinic_locations +
          record.clinic_healthcare_providers +
          record.versions +
          record.review_items
      end

      associations.to_a.any? do |association|
        ((association.try(:updated_at) || association.created_at) -
          teleservice.updated_at).abs < 5.seconds
      end
    end

    if matches_association_timestamps.one?
      return matches_association_timestamps[0]
    elsif matches_association_timestamps.length == 2
      puts "Ambiguous association matches @ #{teleservice.id}!"
    else
      puts "No match for #{teleservice.id}, #{teleservice.teleservice_provider_id}"
    end
  end
end
