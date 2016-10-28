module ProcedureSpecializable
  extend ActiveSupport::Concern

  module ClassMethods
    def procedure_join_table_name
      "#{class.tableize.singularize}_procedures".to_sym
    end
  end

  included do
    has_many procedure_join_table_name
    has_many :procedures, through: procedure_join_table_name
  end

  def primary_specialization_shown_in?(divisions)
    divisions.any? do |division|
      !primary_specialization.hidden_in?(*divisions)
    end
  end

  def primary_specialization
    specializations.sort_by(&:name).first
  end
end
