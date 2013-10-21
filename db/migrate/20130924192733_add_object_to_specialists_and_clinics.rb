class AddObjectToSpecialistsAndClinics < ActiveRecord::Migration
  def change
    add_column :specialists, :review_object, :text
    add_column :clinics, :review_object, :text
    add_column :review_items, :base_object, :text
  end
end
