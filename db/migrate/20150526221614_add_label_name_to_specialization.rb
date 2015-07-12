class AddLabelNameToSpecialization < ActiveRecord::Migration
  def change
    add_column :specializations, :label_name, :string, default: "Specialist"
  end
end
