class AddCityToAddresses < ActiveRecord::Migration
  def change
    rename_column :addresses, :city, :city_old
    add_column :addresses, :city_id, :integer
    
    Address.all.each { |address| 
      next if address.city_old.blank?
      city_name = address.city_old
      city_name = "Westminster" if city_name == "New Westminister"
      city_name = "White Rock" if city_name == "White Rock (South Surrey)"
      address.city = City.find_by_name( city_name.strip )
    }
  end
end
