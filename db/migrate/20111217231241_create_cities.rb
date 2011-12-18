class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.references :province
      
      t.timestamps
    end
    
    City.reset_column_information
    City.create(:name => "White Rock") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Abbotsford") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Burnaby") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Coquitlam") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Langley") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Maple Ridge") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "New Westminster") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "North Vancouver") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Port Coquitlam") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Port Moody") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Surrey") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Terrace") { |c| c.province_id = Province.find_by_symbol("BC").id }
    City.create(:name => "Vancouver") { |c| c.province_id = Province.find_by_symbol("BC").id }
  end
end
