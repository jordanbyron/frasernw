class AddQualityOfEvidenceToEvidences < ActiveRecord::Migration
  def change
    add_column :evidences, :quality_of_evidence, :string
  end
end
