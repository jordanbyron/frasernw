class RemoveRespondsVia < ActiveRecord::Migration
  # derived from other attributes now
  def up
    remove_column :specialists, :responds_via
    remove_column :clinics, :responds_via
  end

  def down
    add_column :specialists, :responds_via, :string
    add_column :clinics, :responds_via, :string
  end
end
