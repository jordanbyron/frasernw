class AddPrimaryContactToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :primary_contact_id, :integer
    
    Division.all.each do |division|
      division_owners = division.specialization_options.reject{ |so| so.owner.blank? }.map{ |so| so.owner }
      division.primary_contact = division_owners.present? ? division_owners.first : default_owner
      division.save
    end
  end
end
