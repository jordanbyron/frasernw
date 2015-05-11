class ChangeClinicResondedToClinicCategorization < ActiveRecord::Migration
  def change
    add_column :clinics, :categorization_mask, :integer, :default => 1

    Clinic.all.each do |c|
      if c.responded
        c.categorization_mask = 1
        else
        c.categorization_mask = 2
      end
      c.save
    end

    remove_column :clinics, :responded
  end
end
