module GenerateClinicSpecialistInputs
  def self.exec(clinic)
    clinic.specializations.inject([]) do |memo, specialization|
      if clinic.specializations.count > 1
        memo << [ "----- #{specialization.name} -----", nil ]
      end
      memo += specialization.specialists.collect { |s| [s.name, s.id] }
    end
  end
end
