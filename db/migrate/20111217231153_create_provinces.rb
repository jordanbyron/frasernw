class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.string :name
      t.string :abbreviation
      t.string :symbol
      
      t.timestamps
    end
    
    Province.create :name => "British Columbia", :abbreviation => "B.C.", :symbol => "BC"
    Province.create :name => "Alberta", :abbreviation => "Alta.", :symbol => "AB"
    Province.create :name => "Manitoba", :abbreviation => "Man.", :symbol => "MB"
    Province.create :name => "New Brunswick", :abbreviation => "N.B.", :symbol => "NB"
    Province.create :name => "Newfoundland and Labrador", :abbreviation => "N.L.", :symbol => "NL"
    Province.create :name => "Northwest Territories", :abbreviation => "N.W.T.", :symbol => "NT"
    Province.create :name => "Nova Scotia", :abbreviation => "N.S.", :symbol => "NS"
    Province.create :name => "Nunavut", :abbreviation => "Nunavut", :symbol => "NU"
    Province.create :name => "Ontario", :abbreviation => "Ont.", :symbol => "ON"
    Province.create :name => "Prince Edward Island", :abbreviation => "P.E.I.", :symbol => "PE"
    Province.create :name => "Quebec", :abbreviation => "Que.", :symbol => "QC"
    Province.create :name => "Saskatchewan", :abbreviation => "Sask.", :symbol => "SK"
    Province.create :name => "Yukon", :abbreviation => "Y.T.", :symbol => "YT"
  end
end


