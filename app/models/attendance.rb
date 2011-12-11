class Attendance < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :clinic
  
  def freeform_name
    firstname + " " + lastname
  end
end
