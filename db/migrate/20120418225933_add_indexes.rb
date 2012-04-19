class AddIndexes < ActiveRecord::Migration
  def change
    
    add_index :addresses, :hospital_id
    add_index :addresses, :clinic_id
    add_index :addresses, :city_id
    
    add_index :attendances, :specialist_id
    add_index :attendances, :clinic_id
    
    add_index :capacities, :specialist_id
    add_index :capacities, :procedure_specialization_id
    
    add_index :cities, :province_id
    
    add_index :clinic_healthcare_providers, :clinic_id
    add_index :clinic_healthcare_providers, :healthcare_provider_id
    
    add_index :clinic_speaks, :clinic_id
    add_index :clinic_speaks, :language_id
    
    add_index :clinic_specializations, :clinic_id
    add_index :clinic_specializations, :specialization_id
    
    add_index :favorites, :specialist_id
    add_index :favorites, :user_id
    
    add_index :focuses, :clinic_id
    add_index :focuses, :procedure_specialization_id
    
    add_index :locations, [:locatable_id, :locatable_type]
    add_index :locations, :hospital_in_id
    add_index :locations, :clinic_in_id
    
    add_index :privileges, :specialist_id
    add_index :privileges, :hospital_id
    
    add_index :procedure_specializations, :procedure_id
    add_index :procedure_specializations, :specialization_id
    
    add_index :referral_forms, [:referrable_id, :referrable_type]
    
    add_index :review_items, [:item_id, :item_type]
    
    add_index :reviews, [:item_id, :item_type]
    
    add_index :schedules, [:schedulable_id, :schedulable_type]
    add_index :schedules, :monday_id
    add_index :schedules, :tuesday_id
    add_index :schedules, :wednesday_id
    add_index :schedules, :thursday_id
    add_index :schedules, :friday_id
    add_index :schedules, :saturday_id
    add_index :schedules, :sunday_id
    
    add_index :specialist_offices, :specialist_id
    add_index :specialist_offices, :office_id
    
    add_index :specialist_speaks, :specialist_id
    add_index :specialist_speaks, :language_id
    
    add_index :specialist_specializations, :specialist_id
    add_index :specialist_specializations, :specialization_id
    
    add_index :user_controls_clinics, :user_id
    add_index :user_controls_clinics, :clinic_id
    
    add_index :user_controls_specialists, :user_id
    add_index :user_controls_specialists, :specialist_id

  end
end
