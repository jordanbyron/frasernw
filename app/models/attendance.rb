class Attendance < ActiveRecord::Base
  attr_accessible :is_specialist, :freeform_firstname, :freeform_lastname, :area_of_focus
  
  belongs_to :specialist
  belongs_to :clinic
  
  def freeform_name
    firstname + " " + lastname
  end
end
