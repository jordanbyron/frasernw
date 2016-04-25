class CreateTeleservices < ActiveRecord::Migration
  def change
    create_table :teleservices do |t|
      t.integer :teleservice_provider_id
      t.integer :teleservice_provider_type
      t.integer :service_type
      t.boolean :telephone, default: false
      t.boolean :video, default: false
      t.boolean :email, default: false
      t.boolean :store, default: false
      t.string :contact_note

      t.timestamps
    end

    add_index :teleservices,
      [:teleservice_provider_id, :teleservice_provider_type],
      name: "index_teleservices_on_provider"
  end
end
