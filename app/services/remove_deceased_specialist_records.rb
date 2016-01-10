class RemoveDeceasedSpecialistRecords < ServiceObject
  def call
    Specialist.deceased.each do |specialist|
      if specialist.version_marked_deceased.created_at < 2.years.ago
        if specialist.destroy
          SystemNotifier.notice("Deceased Specialist deleted successfully: #{specialist.id} #{specialist.name}")
        else
          SystemNotifier.notice("ERROR deleting deceased specialist: #{specialist.id} #{specialist.name}")
        end
      end
    end
  end
end
