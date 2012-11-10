class DivisionSpecialization < ActiveRecord::Base
  belongs_to :division
  belongs_to :specialization
  
  has_many :division_specialization_cities, :dependent => :destroy
  has_many :cities, :through => :division_specialization_cities

  has_paper_trail
end
