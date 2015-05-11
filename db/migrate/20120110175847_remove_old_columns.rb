class RemoveOldColumns < ActiveRecord::Migration
  def change
    #old address data
    remove_column :addresses, :city_old
    remove_column :addresses, :province_old

    #old wait/lag time data
    remove_column :clinics, :lagtime_old
    remove_column :clinics, :lag_uom_old
    remove_column :clinics, :waittime_old
    remove_column :clinics, :wait_uom_old

    remove_column :specialists, :lagtime_old
    remove_column :specialists, :lag_uom_old
    remove_column :specialists, :waittime_old
    remove_column :specialists, :wait_uom_old

    #old address data (now in addresses table)
    remove_column :clinics, :address1
    remove_column :clinics, :address2
    remove_column :clinics, :postalcode
    remove_column :clinics, :city
    remove_column :clinics, :province
    remove_column :clinics, :phone1
    remove_column :clinics, :fax

    remove_column :specialists, :address1
    remove_column :specialists, :address2
    remove_column :specialists, :postalcode
    remove_column :specialists, :city
    remove_column :specialists, :province
    remove_column :specialists, :phone1
    remove_column :specialists, :fax

    remove_column :hospitals, :address1
    remove_column :hospitals, :address2
    remove_column :hospitals, :postalcode
    remove_column :hospitals, :city
    remove_column :hospitals, :province
    remove_column :hospitals, :phone1
    remove_column :hospitals, :fax

    #old one-to-one specialization data
    remove_column :specialists, :specialization_id
    remove_column :clinics, :specialization_id
    remove_column :procedures, :specialization_id

    #old capacity/focus on a procedure, instead of a procedure_specialization
    remove_column :capacities, :procedure_id
    remove_column :focuses, :procedure_id

    #old procedure ancestry data (lives on procedure_specializations)
    remove_index :procedures, :column => :ancestry
    remove_column :procedures, :ancestry
  end
end
