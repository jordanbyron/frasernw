class AddNoAnswerToSpecialists < ActiveRecord::Migration
  def change
    add_column :specialists, :referral_form_mask, :integer, :default => 3
    rename_column :specialists, :referral_form, :referral_form_old
    
    add_column :specialists, :patient_can_book_mask, :integer, :default => 3
    rename_column :specialists, :patient_can_book, :patient_can_book_old
    
    Specialist.all.each do |s|
      s.referral_form_mask      = s.referral_form_old     ? 1 : 2
      s.patient_can_book_mask   = s.patient_can_book_old  ? 1 : 2
      s.save
    end
  
    add_column :clinics, :referral_form_mask, :integer, :default => 3
    rename_column :clinics, :referral_form, :referral_form_old
    
    add_column :clinics, :patient_can_book_mask, :integer, :default => 3
    rename_column :clinics, :patient_can_book, :patient_can_book_old
    
    Clinic.all.each do |c|
      c.referral_form_mask      = c.referral_form_old     ? 1 : 2
      c.patient_can_book_mask   = c.patient_can_book_old  ? 1 : 2
      c.save
    end
  end
end
