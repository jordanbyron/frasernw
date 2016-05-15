class AddClinicLocation < ActiveRecord::Migration
  def change

    rename_column :clinics, :phone, :deprecated_phone
    rename_column :clinics, :fax, :deprecated_fax
    rename_column :clinics, :phone_extension, :deprecated_phone_extension
    rename_column :clinics, :sector_mask, :deprecated_sector_mask
    rename_column :clinics, :url, :deprecated_url
    rename_column :clinics, :email, :deprecated_email
    rename_column :clinics, :schedule_id, :deprecated_schedule_id
    rename_column :clinics, :contact_details, :deprecated_contact_details
    rename_column :clinics,
      :wheelchair_accessible_mask,
      :deprecated_wheelchair_accessible_mask

    Clinic.reset_column_information

    create_table :clinic_locations do |t|
      t.integer :clinic_id
      t.string  :phone
      t.string  :fax
      t.string  :phone_extension
      t.integer :sector_mask, default: 1
      t.string  :url
      t.string  :email
      t.text    :contact_details
      t.integer :wheelchair_accessible_mask, default: 3

      t.timestamps
    end

    ClinicLocation.reset_column_information

    count = 0
    Location.all.reject{ |l| l.locatable_type != 'Clinic' }.each do |l|

      clinic = l.locatable
      puts clinic.name

      cl = ClinicLocation.create(clinic_id: clinic.id)
      cl.phone = clinic.deprecated_phone
      cl.fax = clinic.deprecated_fax
      cl.phone_extension = clinic.deprecated_phone_extension
      cl.sector_mask = clinic.deprecated_sector_mask
      cl.url = clinic.deprecated_url
      cl.email = clinic.deprecated_email
      cl.contact_details = clinic.deprecated_contact_details
      cl.wheelchair_accessible_mask = clinic.deprecated_wheelchair_accessible_mask

      cl.save

      s = Schedule.find_by(schedulable_id: clinic.id, schedulable_type: 'Clinic')

      if s.blank?
        s = cl.create_schedule
      else
        s.schedulable = cl
      end

      s.save

      s.create_monday if s.monday.blank?
      s.create_tuesday if s.tuesday.blank?
      s.create_wednesday if s.wednesday.blank?
      s.create_thursday if s.thursday.blank?
      s.create_friday if s.friday.blank?
      s.create_saturday if s.saturday.blank?
      s.create_sunday if s.sunday.blank?

      l.locatable = cl
      l.save

      count += 1
    end
    puts count
  end
end
