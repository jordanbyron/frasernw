class AddFilesToContentManagement < ActiveRecord::Migration
  def change
    add_column :sc_items, :document_file_name, :string
    add_column :sc_items, :document_content_type, :string
    add_column :sc_items, :document_file_size, :integer
    add_column :sc_items, :document_updated_at, :timestamp
  end
end
