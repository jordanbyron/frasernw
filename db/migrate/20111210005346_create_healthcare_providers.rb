class CreateHealthcareProviders < ActiveRecord::Migration
  def change
    create_table :healthcare_providers do |t|
      t.string :name

      t.timestamps
    end

    HealthcareProvider.reset_column_information
    HealthcareProvider.create :name => "Nurse"
    HealthcareProvider.create :name => "Nurse Practitioner"
    HealthcareProvider.create :name => "Occupational Therapist"
    HealthcareProvider.create :name => "Physiotherapist"
    HealthcareProvider.create :name => "Respiratory Therapist"
    HealthcareProvider.create :name => "Pharmacist"
    HealthcareProvider.create :name => "Dietician"
    HealthcareProvider.create :name => "Social Worker"
    HealthcareProvider.create :name => "Pastoral Care"
    HealthcareProvider.create :name => "Psychologist"
    HealthcareProvider.create :name => "Psych nurse"
    HealthcareProvider.create :name => "Volunteers"
  end
end
