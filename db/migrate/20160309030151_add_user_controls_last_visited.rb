class AddUserControlsLastVisited < ActiveRecord::Migration
  def up
    add_column :user_controls_specialists, :last_visited, :datetime
    add_column :user_controls_clinics, :last_visited, :datetime
  end

  def down
  end
end
