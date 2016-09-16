class RemoveDuplicateTeleservices < ActiveRecord::Migration
  def change
    Specialist.select do |specialist|
      specialist.teleservices.count > 4
    end.each do |specialist|
      Teleservice::SERVICE_TYPES.keys.each do |key|
        specialist.
          teleservices.
          where(service_type: key).
          slice(1..-1).
          reject do |teleservice|
            teleservice.telephone.present? ||
              teleservice.video.present? ||
              teleservice.email.present? ||
              teleservice.store.present? ||
              teleservice.contact_note.present?
          end.each do |teleservice|
            teleservice.destroy
          end
      end
    end
    Clinic.select do |clinic|
      clinic.teleservices.count > 4
    end.each do |clinic|
      Teleservice::SERVICE_TYPES.keys.each do |key|
        clinic.
          teleservices.
          where(service_type: key).
          slice(1..-1).
          reject do |teleservice|
            teleservice.telephone.present? ||
              teleservice.video.present? ||
              teleservice.email.present? ||
              teleservice.store.present? ||
              teleservice.contact_note.present?
          end.each do |teleservice|
            teleservice.destroy
          end
      end
    end
  end
end
