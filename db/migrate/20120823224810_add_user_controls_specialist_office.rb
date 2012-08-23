class AddUserControlsSpecialistOffice < ActiveRecord::Migration
  def change
    create_table :user_controls_specialist_offices do |t|
      t.integer :user_id,  null: false
      t.integer :specialist_office_id,  null: false
      
      t.timestamps
    end
    
    UserControlsSpecialist.all.each do |ucs|
      next if ucs.user.blank? || ucs.specialist.blank?
      
      specialist = ucs.specialist
      user = ucs.user
      
      if specialist.offices.length == 1
        UserControlsSpecialistOffice.create :user_id => user.id, :specialist_office_id => specialist.specialist_offices.first.id
      else
        puts "User #{user.name} controls #{specialist.name} but the specialist has multiple offices. Will need to update by hand"
      end
    end
  end
end
