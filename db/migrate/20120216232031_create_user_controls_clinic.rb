class CreateUserControlsClinic < ActiveRecord::Migration
  def change
    create_table :user_controls_clinics do |t|
      t.integer :user_id
      t.integer :clinic_id

      t.timestamps
    end
  end
end
