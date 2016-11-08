class ScItemProcedure < ActiveRecord::Base
  belongs_to  :sc_item
  belongs_to  :procedure

  # TODO: remove

  belongs_to :sc_item_specialization
  belongs_to :procedure_specialization

  #
end
