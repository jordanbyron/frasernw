class RemoveRespondsVia < ActiveRecord::Migration
  # derived from other attributes now
  def up
    remove_column :specialists, :responds_via
    remove_column :clinics, :responds_via
  end

  def down
  end
end
