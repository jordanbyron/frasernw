class ChangeClinicWaitimeToWaittime < ActiveRecord::Migration
  def change
    remove_column :clinics, :waittime
    remove_column :clinics, :waitime
    add_column :clinics, :waittime, :string
  end
end
