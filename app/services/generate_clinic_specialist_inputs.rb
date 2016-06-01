module GenerateClinicSpecialistInputs
  # for #update
  def self.exec(clinic)
    clinic.specializations.inject([]) do |memo, specialization|
      if clinic.specializations.count > 1
        memo << [ "----- #{specialization.name} -----", nil ]
      end
      memo += specialization.specialists.
        sort_by(&:lastname).
        collect { |s| [s.name, s.id] }
    end
  end
end
