class AddCityToAddresses < ActiveRecord::Migration
  def change
    rename_column :addresses, :city, :city_old
    rename_column :addresses, :province, :province_old
    add_column :addresses, :city_id, :integer

    Address.all.each { |address|
      next if address.city_old.blank?
      city_name = address.city_old.strip
      city_name = "Langley" if city_name == "Langely"
      city_name = "Langley" if city_name == "Langly"
      city_name = "New Westminster" if city_name == "New Westminister"
      city_name = "White Rock" if city_name == "White Rock (South Surrey)"
      address.city = City.find_by_name( city_name )
      address.save
    }
  end
end
