class AddPublicEmailToSpecialistOffice < ActiveRecord::Migration
  def change
    add_column :specialist_offices, :public_email, :string
    add_column :clinic_locations, :public_email, :string
  end
end
