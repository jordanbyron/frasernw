class ScItemSpecializationProcedureSpecialization < ActiveRecord::Base
  belongs_to  :sc_item_specialization
  belongs_to  :procedure_specialization
end
