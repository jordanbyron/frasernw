class AddClinicFields < ActiveRecord::Migration
  def change
    add_column :clinics, :contact_details, :text
    add_column :clinics, :status_details, :text
  end
end
