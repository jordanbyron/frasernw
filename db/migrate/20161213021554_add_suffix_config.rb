class AddSuffixConfig < ActiveRecord::Migration
  def up
    add_column :specialists, :tagged_specialization_id, :integer
    add_column :specializations, :global_member_tag, :boolean, default: false
    rename_column :specializations, :suffix, :member_tag

    Specialization.where(name: "Pediatrics").update_all(member_tag: "Ped")
    Specialization.where(name: "Internal Medicine").update_all(member_tag: "Int Med")
    Specialization.where(name: "General Surgery").update_all(member_tag: "Gen Surgeon")
    Specialization.where(name: "Neurology").update_all(member_tag: "Neurologist")
    Specialization.where(name: "ENT / Otolaryngology").update_all(member_tag: "ENT")

    Specialization.where(name: "Nurse Practitioner").update_all(global_member_tag: true)
    Specialization.where(name: "Midwifery").update_all(global_member_tag: true)
    Specialization.where(name: "Family Practice").update_all(global_member_tag: true)

    Specialist.
      where(is_gp: true).
      update_all(
        tagged_specialization_id: Specialization.find_by(name: "Family Practice").id
      )

    Specialist.
      where(is_internal_medicine: true).
      update_all(
        tagged_specialization_id: Specialization.find_by(name: "Internal Medicine").id
      )

    Specialist.
      where(sees_only_children: true).
      update_all(
        tagged_specialization_id: Specialization.find_by(name: "Pediatrics").id
      )

    Specialization.
      find_by(name: "Nurse Practitioner").
      specialists.
      update_all(
        tagged_specialization_id: Specialization.find_by(name: "Nurse Practitioner").id
      )

    Specialization.
      find_by(name: "Midwifery").
      specialists.
      update_all(
        tagged_specialization_id: Specialization.find_by(name: "Midwifery").id
      )
  end
end
