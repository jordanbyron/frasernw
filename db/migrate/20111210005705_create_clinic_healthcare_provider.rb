class CreateClinicHealthcareProvider < ActiveRecord::Migration
  def change
    create_table :clinic_healthcare_providers do |t|
      t.integer :clinic_id
      t.integer :healthcare_provider_id

      t.timestamps
    end
  end
end
