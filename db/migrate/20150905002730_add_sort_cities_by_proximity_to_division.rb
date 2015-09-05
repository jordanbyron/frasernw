class AddSortCitiesByProximityToDivision < ActiveRecord::Migration
  def up
    add_column :divisions, :sort_cities_by_proximity, :boolean, default: false
  end

  def down
    remove_column :division, :sort_cities_by_proximity
  end
end
