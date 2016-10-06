class Attendance < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :clinic_location

  include PaperTrailable

  def freeform_name
    freeform_firstname or ""
    #(freeform_firstname or "") + " " + (freeform_lastname or "")
  end

  def has_clinic_location?
    !(clinic_location.blank?) && !(clinic_location.empty?)
  end

  def has_available_specialist?
    specialist.present? && specialist.available_for_work?
  end

  def show?
    if is_specialist?
      has_clinic_location? && has_available_specialist?
    else
      has_clinic_location? && !(freeform_name.blank?)
    end
  end
end
