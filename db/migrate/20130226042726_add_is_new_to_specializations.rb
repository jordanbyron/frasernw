class AddIsNewToSpecializations < ActiveRecord::Migration
  def change
    add_column :specialization_options, :is_new, :boolean, :default => false
  end
end
