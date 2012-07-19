class AddSearchableToContentItems < ActiveRecord::Migration
  def change
    add_column :sc_items, :searchable, :boolean, :default => true
  end
end
