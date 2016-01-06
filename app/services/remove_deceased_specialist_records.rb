class RemoveDeceasedSpecialistRecords < ServiceObject
  def call
    Specialist.deceased.each do |specialist|
      if specialist.version_marked_deceased.created_at < 2.years.ago
        sname = specialist.name
        sid = specialist.id
        if specialist.destroy
          SystemNotifier.notice("Deceased Specialist deleted successfully: #{sid} #{sname}")
        else
          SystemNotifier.notice("ERROR deleting deceased specialist: #{sid} #{sname}")
        end
      end
    end
  end
end
