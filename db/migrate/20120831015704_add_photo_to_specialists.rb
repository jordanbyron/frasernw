class AddPhotoToSpecialists < ActiveRecord::Migration
  def change
    add_column :specialists, :photo_file_name, :string
    add_column :specialists, :photo_content_type, :string
    add_column :specialists, :photo_file_size, :integer
    add_column :specialists, :photo_updated_at, :timestamp
  end
end
