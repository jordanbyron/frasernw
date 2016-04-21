class AddSeesChildrenOnlyToSpecialist < ActiveRecord::Migration
  def change
    add_column :specialists, :sees_children_only, :boolean, default: false

    pediatricians = Specialist.includes(:specialist_specializations).
      where(specialist_specializations: {specialization_id: 31}).each do |ped|
        ped.
  end
end
