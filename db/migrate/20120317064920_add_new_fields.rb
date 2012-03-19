class AddNewFields < ActiveRecord::Migration
  def change
    add_column :specialists, :goes_by_name, :string
    add_column :specialists, :direct_phone_extension, :string
    add_column :specialists, :sex_mask, :integer, :default => 3
    add_column :specialists, :referral_details, :text
    add_column :specialists, :admin_notes, :text
    
    add_column :specialist_offices, :phone_extension, :string
    add_column :specialist_offices, :sector_mask, :integer
    
    SpecialistOffice.all.each do |so|
      if so.empty?
        so.sector_mask = 4
      else
        so.sector_mask = 1
      end
      so.save
    end
    
    add_column :clinics, :sector_mask, :integer, :default => 1
    add_column :clinics, :wheelchair_accessible_mask, :integer, :default => 3
    add_column :clinics, :referral_details, :text
    add_column :clinics, :admin_notes, :text
  end
end
