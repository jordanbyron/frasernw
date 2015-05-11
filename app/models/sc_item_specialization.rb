class ScItemSpecialization < ActiveRecord::Base
  belongs_to  :sc_item
  belongs_to  :specialization

  has_many    :sc_item_specialization_procedure_specializations, :dependent => :destroy
  has_many    :procedure_specializations, :through => :sc_item_specialization_procedure_specializations
end
