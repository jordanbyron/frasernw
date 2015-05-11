class AddClinicSpeaks < ActiveRecord::Migration
  def change
    create_table :clinic_speaks do |t|
      t.integer :clinic_id
      t.integer :language_id

      t.timestamps
    end
  end
end
