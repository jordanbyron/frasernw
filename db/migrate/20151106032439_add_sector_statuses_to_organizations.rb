class AddSectorStatusesToOrganizations < ActiveRecord::Migration
  def up
    [
      ClinicLocation,
      SpecialistOffice
    ].each do |klass|
      add_column klass.table_name, :public, :boolean
      add_column klass.table_name, :private, :boolean
      add_column klass.table_name, :volunteer, :boolean

      klass.all.each do |record|
        case record.sector_mask
        when 1
          record.update_attributes(
            public: true,
            private: false,
            volunteer: false
          )
        when 2
          record.update_attributes(
            public: false,
            private: true,
            volunteer: false
          )
        when 3
          record.update_attributes(
            public: true,
            private: true,
            volunteer: false
          )
        when 4
          record.update_attributes(
            public: nil,
            private: nil,
            volunteer: nil
          )
        else
          record.update_attributes(
            public: nil,
            private: nil,
            volunteer: nil
          )
        end
      end
    end
  end

  def down
  end
end
