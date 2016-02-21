class RemoveSummaryFromEvidences < ActiveRecord::Migration
  def up
    remove_column :evidences, :summary
  end

  def down
    add_column :evidences, :summary, :string
  end
end
