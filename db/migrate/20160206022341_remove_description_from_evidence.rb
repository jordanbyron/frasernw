class RemoveDescriptionFromEvidence < ActiveRecord::Migration
  def up
    remove_column :evidences, :description
  end

  def down
    add_column :evidences, :description, :string
  end
end
