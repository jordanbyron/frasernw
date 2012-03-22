class AddPatientInstructionsAndCancellationPolicy < ActiveRecord::Migration
  def change
    
    add_column :specialists, :patient_instructions, :text
    add_column :specialists, :cancellation_policy, :text
    
    add_column :clinics, :patient_instructions, :text
    add_column :clinics, :cancellation_policy, :text
    
  end
end
