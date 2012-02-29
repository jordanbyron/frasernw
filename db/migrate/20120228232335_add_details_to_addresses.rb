class AddDetailsToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :details, :string
    
    Address.all.each do |a|
      a.details = a.address2
      a.save
    end
  end
end
