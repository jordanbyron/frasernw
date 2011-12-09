class AddMoreFieldsToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :required_investigations, :text
    add_column :clinics, :not_performed, :text
    add_column :clinics, :referral_fax, :boolean
    add_column :clinics, :referral_phone, :boolean
    add_column :clinics, :referral_other_details, :string
    add_column :clinics, :referral_form, :boolean
    add_column :clinics, :lagtime, :string
    add_column :clinics, :lag_uom, :string
    add_column :clinics, :waitime, :string
    add_column :clinics, :wait_uom, :string
    add_column :clinics, :respond_by_fax, :boolean
    add_column :clinics, :respond_by_phone, :boolean
    add_column :clinics, :respond_by_mail, :boolean
    add_column :clinics, :respond_to_patient, :boolean
    add_column :clinics, :patient_can_book, :boolean
    add_column :clinics, :red_flags, :text
    add_column :clinics, :urgent_fax, :boolean
    add_column :clinics, :urgent_phone, :boolean
    add_column :clinics, :urgent_other_details, :string
  end
end
