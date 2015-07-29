module ProcedureSpecializable
  extend ActiveSupport::Concern

  def has_ps_arrangement?(arrangement)
    ps_from_arrangement(arrangement).present?
  end

  def ps_from_arrangement(arrangement)
    procedure_specializations.find do |procedure_specialization|
      procedure_specialization.matches_arrangement?(arrangement)
    end
  end

  module ClassMethods
    def with_ps_arrangement(arrangement)
      all.select do |clinic|
        clinic.has_ps_arrangement?(arrangement)
      end
    end
  end
end
