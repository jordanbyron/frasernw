class AddContactDetailsToSpecialistOffices < ActiveRecord::Migration
  def change
    add_column :specialist_offices, :contact_details, :text
  end
end
