class AddSpecializationOptions < ActiveRecord::Migration
  def change
    rename_table :specialization_owners, :specialization_options
    add_column :specialization_options, :in_progress, :boolean, default: false
    add_column :specialization_options, :open_to_clinic_tab, :boolean, default: false

    Specialization.all.each do |s|
      Division.all.each do |d|
        so = SpecializationOption.
          find_or_create_by(specialization_id: s.id, division_id: d.id)
        so.in_progress = s.in_progress
        so.open_to_clinic_tab = s.open_to_clinic_tab
        so.save
      end
    end

    rename_column :specializations, :open_to_clinic_tab, :deprecated_open_to_clinic_tab
    rename_column :specializations, :in_progress, :deprecated_in_progress
  end
end
