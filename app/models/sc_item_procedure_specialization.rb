class ScItemProcedureSpecialization < ActiveRecord::Base
  belongs_to  :sc_item
  belongs_to  :procedure_specialization
end
