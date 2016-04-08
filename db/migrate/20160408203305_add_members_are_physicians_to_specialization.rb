class AddMembersArePhysiciansToSpecialization < ActiveRecord::Migration
  def up
    add_column :specializations, :members_are_physicians, :boolean, default: true

    Specialization.
      where(name: ["Midwifery", "Nurse Practitioner"]).
      update_all(members_are_physicians: false)
  end

  def down
    remove_column :specializations, :members_are_physicians
  end
end
