class AddMoreIndexes < ActiveRecord::Migration
  def change

    add_index :sc_items, :sc_category_id

    add_index :sc_item_specializations, :sc_item_id
    add_index :sc_item_specializations, :specialization_id

    add_index :sc_item_specialization_procedure_specializations, :sc_item_specialization_id, :name => "index_sc_item_sps_on_sc_item_specialization_id"
    add_index :sc_item_specialization_procedure_specializations, :procedure_specialization_id, :name => "index_sc_item_sps_on_procedure_specialization_id"

  end
end
