class AddWaitTimeToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :waittime_mask, :integer
    rename_column :clinics, :waittime, :waittime_old
    rename_column :clinics, :wait_uom, :wait_uom_old
    
    add_column :clinics, :lagtime_mask, :integer
    rename_column :clinics, :lagtime, :lagtime_old
    rename_column :clinics, :lag_uom, :lag_uom_old
    
    add_column :specialists, :waittime_mask, :integer
    rename_column :specialists, :waittime, :waittime_old
    rename_column :specialists, :wait_uom, :wait_uom_old
    
    add_column :specialists, :lagtime_mask, :integer
    rename_column :specialists, :lagtime, :lagtime_old
    rename_column :specialists, :lag_uom, :lag_uom_old
  end
end
