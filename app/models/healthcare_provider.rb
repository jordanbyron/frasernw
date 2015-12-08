class HealthcareProvider < ActiveRecord::Base
  attr_accessible :name
  include PaperTrailable

  has_many :clinic_healthcare_provider, :dependent => :destroy
  has_many :clinics, :through => :clinic_healthcare_provider

  validates_presence_of :name, :on => :create, :message => "can't be blank"

  scope :ordered_by_name, -> { order("name ASC") }
end
