class AddInterpreterToSpecialists < ActiveRecord::Migration
  def change
    add_column :specialists, :interpreter_available, :boolean, :default => false
    add_column :clinics, :interpreter_available, :boolean, :default => false
  end
end
