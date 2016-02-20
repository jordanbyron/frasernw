class AddDefinitionToEvidences < ActiveRecord::Migration
  def up
    add_column :evidences, :definition, :text
  end

  def down
    remove_column :evidences, :definition, :text
  end
end
