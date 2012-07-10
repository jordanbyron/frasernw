class AddScItemProcedureSpecialization < ActiveRecord::Migration
  def change
    create_table :sc_item_specialization_procedure_specializations do |t|
      t.integer :sc_item_specialization_id
      t.integer :procedure_specialization_id
      
      t.timestamps
    end
  end
end
