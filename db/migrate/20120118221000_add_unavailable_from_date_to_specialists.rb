class AddUnavailableFromDateToSpecialists < ActiveRecord::Migration
  def change
    add_column :specialists, :unavailable_from, :date
    add_column :specialists, :unavailable_to, :date
  end
end
