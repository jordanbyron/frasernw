class RemoveDeceasedSpecialistRecords < ServiceObject
  def call
    Specialist.deceased.each do |specialist|
      if specialist.version_marked_deceased.created_at < 2.years.ago
        specialist.destroy
      end
    end
  end
end
