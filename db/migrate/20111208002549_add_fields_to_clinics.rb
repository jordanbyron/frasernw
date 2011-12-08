class AddFieldsToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :contact_name, :string
    add_column :clinics, :contact_phone, :string
    add_column :clinics, :contact_email, :string
    add_column :clinics, :contact_notes, :string
    add_column :clinics, :status_mask, :integer
    add_column :clinics, :limitations, :text
    add_column :clinics, :location_opened, :text
  end
end
