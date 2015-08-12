module ProcedureSpecializable
  extend ActiveSupport::Concern

  def procedure_specialize_in!(procedure_specialization_id)
    procedure_specialization_links.find_or_create_by_procedure_specialization_id(procedure_specialization_id)
  end

  def has_ps_with_ancestry?(ancestry)
    procedure_specializations_from_ancestry(ancestry).present?
  end

  def procedure_specializations_from_ancestry(ancestry)
    procedure_specializations.find do |procedure_specialization|
      procedure_specialization.matches_ancestry?(ancestry)
    end
  end

  module ClassMethods
    def with_ps_with_ancestry(ancestry)
      all.select do |clinic|
        clinic.has_ps_with_ancestry?(ancestry)
      end
    end
  end
end
