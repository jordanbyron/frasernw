class AddSectorStatusesToClinicLocations < ActiveRecord::Migration
  def up
    add_column :clinic_locations, :public, :boolean
    add_column :clinic_locations, :private, :boolean
    add_column :clinic_locations, :volunteer, :boolean

    ClinicLocation.all.each do |clinic_location|
      case clinic_location.sector_mask
      when 1
        clinic_location.update_attributes(
          public: true,
          private: false,
          volunteer: false
        )
      when 2
        clinic_location.update_attributes(
          public: false,
          private: true,
          volunteer: false
        )
      when 3
        clinic_location.update_attributes(
          public: true,
          private: true,
          volunteer: false
        )
      when 4
        clinic_location.update_attributes(
          public: nil,
          private: nil,
          volunteer: nil
        )
      else
        clinic_location.update_attributes(
          public: nil,
          private: nil,
          volunteer: nil
        )
      end
    end
  end

  def down
  end
end
