class AddPhoneScheduleToSpecialistOffice < ActiveRecord::Migration
  def change
    add_column :specialist_offices, :schedule_id, :integer
    
    SpecialistOffice.all.each do |so|
      s = so.build_phone_schedule
      s.build_monday.save
      s.build_tuesday.save
      s.build_wednesday.save
      s.build_thursday.save
      s.build_friday.save
      s.build_saturday.save
      s.build_sunday.save
      s.save
    end
  end
end
