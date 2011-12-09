class AddInvestigationsToFocuses < ActiveRecord::Migration
  def change
    add_column :focuses, :investigation, :string
    add_index :focuses, [:clinic_id, :procedure_id]
  end
end
