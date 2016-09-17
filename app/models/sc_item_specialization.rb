class ScItemSpecialization < ActiveRecord::Base
  belongs_to :sc_item
  belongs_to :specialization

  has_many :sc_item_specialization_procedures, dependent: :destroy
  has_many :procedures, through: :sc_item_specialization_procedures
end
