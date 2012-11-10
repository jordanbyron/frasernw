class Division < ActiveRecord::Base
  
  attr_accessible :name, :city_ids
   
  has_many :division_cities, :dependent => :destroy
  has_many :cities, :through => :division_cities
  
  has_many :division_specializations, :dependent => :destroy
  has_many :specializations, :through => :division_specializations
  
  has_many :division_specialization_cities, :through => :division_specializations
  has_many :local_referral_cities, :through => :division_specialization_cities, :class_name => "Division", :source => :city
  
  has_paper_trail
  
  default_scope order('divisions.name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  def to_s
    self.name
  end
  
  def local_referral_cities_for_specialization(specialization)
    division_specialization = DivisionSpecialization.find_by_division_id_and_specialization_id(self.id, specialization.id)
    if division_specialization.present? && division_specialization.cities.present?
      return division_specialization.cities
    else
      return cities
    end
  end
end
