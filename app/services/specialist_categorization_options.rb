class SpecialistCategorizationOptions < ServiceObject
  attribute :built_specialization
  attribute :specialist
  attribute :default_divisions

  def call
    if specializations.any?
      from_specializations_and_divisions
    else
      Specialist::CATEGORIZATION_LABELS
    end
  end

  def from_specializations_and_divisions
    specializations.map do |specialization|
      specialization.specialization_options.for_divisions(divisions)
    end.
      flatten.
      uniq.
      inject({}) do |memo, specialization_option|
        memo.merge(specialization_option.specialist_categorization_hash)
      end
  end

  def specializations
    @specializations ||= begin
      if built_specialization.present?
        [ built_specialization ]
      else
        specialist.specializations
      end
    end
  end

  def divisions
    @divisions ||= begin
      if specialist.divisions.any?
        specialist.divisions
      else
        default_divisions
      end
    end
  end
end
