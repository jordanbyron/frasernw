class Attendance < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :clinic_location

  include PaperTrailable

  def freeform_name
    freeform_firstname or ""
    #(freeform_firstname or "") + " " + (freeform_lastname or "")
  end
end
