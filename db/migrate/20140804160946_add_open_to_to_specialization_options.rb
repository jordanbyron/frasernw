class AddOpenToToSpecializationOptions < ActiveRecord::Migration
  def change
    add_column :specialization_options, :open_to_type, :int, :default => SpecializationOption::OPEN_TO_SPECIALISTS
    add_column :specialization_options, :open_to_sc_category_id, :int
    rename_column :specialization_options, :open_to_clinic_tab, :open_to_clinic_tab_old

    SpecializationOption.all.each do |so|
      if so.open_to_clinic_tab_old
        puts "#{so.specialization.name} opens to clinic tab in #{so.division.name}"
        so.open_to_type = SpecializationOption::OPEN_TO_CLINICS
        so.save
      end
    end
  end
end
