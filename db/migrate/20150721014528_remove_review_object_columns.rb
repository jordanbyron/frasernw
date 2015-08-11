class RemoveReviewObjectColumns < ActiveRecord::Migration
  def up
    remove_column :specialists, :review_object
    remove_column :clinics, :review_object
  end

  def down
    add_column :specialists, :review_object, :text
    add_column :specialists, :review_object, :text
  end
end
