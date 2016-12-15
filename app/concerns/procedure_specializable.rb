module ProcedureSpecializable
  extend ActiveSupport::Concern

  def procedure_specialize_in!(procedure_specialization_id)
    procedure_specialization_links.find_or_create_by(
      procedure_specialization_id: procedure_specialization_id
    )
  end

  def has_ps_with_ancestry?(ancestry)
    procedure_specialization_from_ancestry(ancestry).present?
  end

  def has_ps_ancestry?(ancestry)
    matching_ps =
      procedure_specialization_from_ancestry(ancestry)

    matching_ps.present? &&
      procedure_specializations.includes_array?(matching_ps.ancestors)
  end

  def procedure_specialization_from_ancestry(ancestry)
    procedure_specializations.find do |procedure_specialization|
      procedure_specialization.matches_ancestry?(ancestry)
    end
  end

  # We assume that they also do parent procedures
  def procedure_ids_with_parents
    procedure_specializations.includes(:procedure).map do |ps|
      [ ps.procedure.id, ps.ancestor_procedure_ids ]
    end.flatten
  end

  module ClassMethods
    def with_ps_with_ancestry(ancestry)
      all.select do |procedure_specializable|
        procedure_specializable.has_ps_with_ancestry?(ancestry)
      end
    end

    def with_ps_ancestry(ancestry)
      all.select do |procedure_specializable|
        procedure_specializable.has_ps_ancestry?(ancestry)
      end
    end
  end
end
