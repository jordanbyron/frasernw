class AddDivisionToSpecializationOwner < ActiveRecord::Migration
  def change
    add_column :specialization_owners, :division_id, :integer
  end
end
