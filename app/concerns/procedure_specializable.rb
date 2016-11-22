module ProcedureSpecializable
  extend ActiveSupport::Concern

  module ClassMethods
    def procedure_specialize_as(target_name)
      has_many "#{target_name}_procedures".to_sym
      has_many :procedure_links, class_name: "#{target_name.classify}Procedure"
      has_many :procedures, through: "#{target_name}_procedures".to_sym
      accepts_nested_attributes_for "#{target_name}_procedures".to_sym,
        allow_destroy: true
      attr_accessible "#{target_name}_procedures_attributes".to_sym

      has_many "#{target_name}_specializations".to_sym, dependent: :destroy
      has_many :specialization_links,
        class_name: "#{target_name.classify}Specialization"
      accepts_nested_attributes_for "#{target_name}_specializations".to_sym,
        allow_destroy: true
      has_many :specializations, through: "#{target_name}_specializations".to_sym
      attr_accessible "#{target_name}_specializations_attributes".to_sym
    end
  end

  def primary_specialization_shown_in?(divisions)
    divisions.any? do |division|
      !primary_specialization.hidden_in?(*divisions)
    end
  end

  def primary_specialization
    specializations.sort_by(&:name).first
  end

  def nested_procedures(arg)
    case arg
    when Specialization
      nested_procedures(
        arg.
          procedure_specializations.
          non_assumed(self.class).
          arrange
      )
    when ActiveSupport::OrderedHash
      arg.inject({}) do |memo, (procedure_specialization, children)|
        if procedures.include?(procedure_specialization.procedure)
          memo.merge(
            procedure_specialization.procedure => nested_procedures(children)
          )
        else
          memo
        end
      end
    end
  end
end
