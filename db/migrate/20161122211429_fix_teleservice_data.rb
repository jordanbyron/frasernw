class FixTeleserviceData < ActiveRecord::Migration
  def change
    Teleservice.all.reject do |teleservice|
      teleservice.telephone.present? ||
        teleservice.video.present? ||
        teleservice.email.present? ||
        teleservice.store.present? ||
        teleservice.contact_note.present?
    end.each do |teleservice|
      teleservice.destroy
    end

    Teleservice.all.each do |teleservice|
      if Specialist.exists?(teleservice.teleservice_provider_id)
        if Clinic.exists?(teleservice.teleservice_provider_id)
          specialist = Specialist.find(teleservice.teleservice_provider_id)
          if (specialist.created_at == teleservice.created_at) || (
            specialist.updated_at ==
              (teleservice.updated_at || teleservice.created_at)
          )
            puts "Specialist! ID #{teleservice.id}"
            teleservice.update_attributes(teleservice_provider_type: "Specialist")
          else
            clinic = Clinic.find(teleservice.teleservice_provider_id)
            if (clinic.created_at == teleservice.created_at) || (
              clinic.updated_at ==
                (teleservice.updated_at || teleservice.created_at)
            )
              puts "Clinic! ID #{teleservice.id}"
              teleservice.update_attributes(teleservice_provider_type: "Clinic")
            else
              puts "No match: ID #{teleservice.id}"
            end
          end
        else
          teleservice.update_attributes(teleservice_provider_type: "Specialist")
        end
      elsif Clinic.exists?(teleservice.teleservice_provider_id)
        teleservice.update_attributes(teleservice_provider_type: "Clinic")
      else
        raise "Orphaned teleservice: ID #{teleservice.id}"
      end
    end
  end
end
