class SpecializationOption < ActiveRecord::Base
  attr_accessible :specialization, :owner, :division, :in_progress, :open_to_clinic_tab
  
  belongs_to :specialization
  belongs_to :owner, :class_name => "User"
  belongs_to :division
  
  def self.for_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where("specialization_options.division_id IN (?)", division_ids)
  end
  
  has_paper_trail
end
