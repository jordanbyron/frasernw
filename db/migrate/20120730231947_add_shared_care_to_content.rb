class AddSharedCareToContent < ActiveRecord::Migration
  def change
    add_column :sc_items, :shared_care, :boolean, :default => false
  end
end
