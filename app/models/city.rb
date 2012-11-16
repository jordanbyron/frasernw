class City < ActiveRecord::Base
  attr_accessible :name, :province_id
  has_paper_trail
  
  belongs_to :province
  has_many :addresses
  has_many :locations, :through => :addresses
  
  has_many :division_cities, :dependent => :destroy
  has_many :divisions, :through => :division_cities
  
  default_scope order('cities.name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  def to_s
    self.name
  end
  
  def self.in_divisions(divisions)
    division_ids = divisions.map{ |division| division.id }
    joins('INNER JOIN "division_cities" ON "cities".id = "division_cities".city_id').where('"division_cities".division_id IN (?)', division_ids)
  end
  
  def self.for_user_in_specialization(user, specialization)
    #user defined
    per_user = joins('INNER JOIN "user_cities" ON "user_cities".city_id = "cities".id INNER JOIN "user_city_specializations" ON "user_cities".id = "user_city_specializations".user_city_id').where('"user_city_specializations".specialization_id = (?) AND "user_cities".user_id = (?)', specialization.id, user.id)
    #user is in division which has cities for specialization
    per_specialty = joins('INNER JOIN "division_specialization_cities" ON "division_specialization_cities".city_id = "cities".id INNER JOIN "division_specializations" ON "division_specializations".id = "division_specialization_cities".division_specialization_id INNER JOIN "division_users" ON "division_users".division_id = "division_specializations".division_id').where('"division_specializations".specialization_id = (?) AND "division_users".user_id = (?)', specialization.id, user.id)
    #user is in division which has default cities
    divisional = joins('INNER JOIN "division_cities" ON "division_cities".city_id = "cities".id INNER JOIN "division_users" ON "division_users".division_id = "division_cities".division_id').where('"division_users".user_id = (?)', user.id)

    if per_user.present?
      return per_user
    elsif per_specialty.present?
      return per_specialty
    else
      return divisional
    end
  end
end
