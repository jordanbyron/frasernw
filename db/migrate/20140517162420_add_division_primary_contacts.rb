class AddDivisionPrimaryContacts < ActiveRecord::Migration
  def change
    create_table :division_primary_contacts do |t|
      t.integer :division_id
      t.integer :primary_contact_id
      
      t.timestamps
    end
    
    Division.all.each do |division|
      DivisionPrimaryContact.create(:division => division, :primary_contact_id => division.primary_contact_id)
    end
  end
end
