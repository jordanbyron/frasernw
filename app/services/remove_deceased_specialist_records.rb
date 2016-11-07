class RemoveDeceasedSpecialistRecords < ServiceObject
  def call
    Specialist.all.select do |specialist|
      specialist.is_deceased? && specialist.practice_end_date < 2.years.ago
    end.map(&:destroy)
  end
end
