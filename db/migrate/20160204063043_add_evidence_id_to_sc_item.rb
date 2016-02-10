class AddEvidenceIdToScItem < ActiveRecord::Migration
  def up
    add_column :sc_items, :evidence_id, :integer
    add_index :sc_items, :evidence_id
  end

  def down
    remove_column :sc_items, :evidence_id
  end
end
