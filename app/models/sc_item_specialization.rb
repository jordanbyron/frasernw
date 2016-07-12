class ScItemSpecialization < ActiveRecord::Base
  belongs_to :sc_item
  belongs_to :specialization

  has_many :content_item_specialty_area_of_practice_specialties, dependent: :destroy
  has_many :procedure_specializations,
    through: :content_item_specialty_area_of_practice_specialties
end
