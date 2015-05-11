class CreateUserControlsSpecialist < ActiveRecord::Migration
  def change
    create_table :user_controls_specialists do |t|
      t.integer :user_id
      t.integer :specialist_id

      t.timestamps
    end
  end
end
