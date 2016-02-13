class AddSummaryToEvidence < ActiveRecord::Migration
  def change
    add_column :evidences, :summary, :string
  end
end
