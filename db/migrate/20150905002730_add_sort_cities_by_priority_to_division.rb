class AddSortCitiesByPriorityToDivision < ActiveRecord::Migration
  def up
    add_column :divisions, :use_customized_city_priorities, :boolean, default: false
  end

  def down
    remove_column :division, :use_customized_city_priorities
  end
end
