require 'awesome_print'

class RemoveDuplicateAttendances < ActiveRecord::Migration
  def up
    destroyed_attendances = []

    Attendance.all.each do |attendance|
      if attendance.area_of_focus.is_a?(String)
        attendance.update_attribute(:area_of_focus, attendance.area_of_focus.strip)
      end
    end

    ClinicLocation.all.each do |clinic_location|
      existing_specialists = []

      clinic_location.attendances.each do |attendance|
        next if !attendance.is_specialist

        keys_to_unique_by = [
          attendance.specialist_id,
          attendance.area_of_focus
        ]

        if existing_specialists.include?(keys_to_unique_by)
          destroyed_attendances << attendance

          attendance.destroy
        else
          existing_specialists << keys_to_unique_by
        end
      end
    end

    ap destroyed_attendances

    destroyed_attendances.each do |attendance|
      if !Attendance.exists?(attendance.attributes.slice(:clinic_location_id, :specialist_id, :area_of_focus))
        raise attendance
      end
    end
  end

  def down
  end
end
