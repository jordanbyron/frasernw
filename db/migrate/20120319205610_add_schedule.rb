class AddSchedule < ActiveRecord::Migration
  def change
    
    create_table :schedules do |t|
      t.string  :schedulable_type
      t.integer :schedulable_id
      t.integer :monday_id
      t.integer :tuesday_id
      t.integer :wednesday_id
      t.integer :thursday_id
      t.integer :friday_id
      t.integer :saturday_id
      t.integer :sunday_id
      
      t.timestamps
    end
    
    create_table :schedule_days do |t|
      t.boolean :scheduled
      t.time    :from
      t.time    :to
      
      t.timestamps
    end
    
    add_column :specialist_offices, :schedule_id, :integer
    
    SpecialistOffice.all.each do |so|
      s = so.build_schedule
      s.build_monday
      s.build_tuesday
      s.build_wednesday
      s.build_thursday
      s.build_friday
      s.build_saturday
      s.build_sunday
      so.save
    end
    
    add_column :clinics, :schedule_id, :integer
    
    Clinic.all.each do |c|
      s = c.build_schedule
      s.build_monday
      s.build_tuesday
      s.build_wednesday
      s.build_thursday
      s.build_friday
      s.build_saturday
      s.build_sunday
      c.save
    end
    
  end
end
