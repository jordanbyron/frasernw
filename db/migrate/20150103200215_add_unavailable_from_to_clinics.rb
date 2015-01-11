class AddUnavailableFromToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :unavailable_from, :date
  end
end
