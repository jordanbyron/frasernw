class AddDirectPhonePerOffice < ActiveRecord::Migration
  def change
    add_column :specialist_offices, :direct_phone, :string
    add_column :specialist_offices, :direct_phone_extension, :string
    
    rename_column :specialists, :direct_phone, :direct_phone_old
    rename_column :specialists, :direct_phone_extension, :direct_phone_extension_old
    
    Specialist.all.each do |s|
      if ((s.offices.length > 2) && s.direct_phone.present?)
        say "#{s.name} has two offices with a single direct phone number #{s.direct_phone}"
      end
      
      next if (s.direct_phone_old.strip.downcase == "no" || s.direct_phone_old.strip.downcase == "none")
      
      s.specialist_offices.each do |so|
        so.direct_phone = s.direct_phone_old
        so.direct_phone_extension = s.direct_phone_extension_old
        so.save
      end
    end
    
    #TODO remove columnsx
  end
end
