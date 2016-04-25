class AddSeesOnlyChildrenToSpecialist < ActiveRecord::Migration
  def up
    add_column :specialists, :sees_only_children, :boolean, default: false

    pediatricians = Specialist.joins(:specializations).where(specializations: {id: 31}).
      select{ |pediatrician| pediatrician.specialization_ids.count > 1 }.
      reject{ |pediatrician| [1804,658,883,2286,1557,1387].include?(pediatrician.id) }

    pediatricians.each do |pediatrician|
      pediatrician.update_column(:sees_only_children, true)
    end
  end

  def down
    remove_column :specialists, :sees_only_children
  end
end
