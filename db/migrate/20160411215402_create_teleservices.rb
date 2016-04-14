class CreateTeleservices < ActiveRecord::Migration
  def change
    create_table :teleservices do |t|
      t.references :specialist, index: true
      t.integer :service_type
      t.boolean :telephone
      t.boolean :video
      t.boolean :email
      t.boolean :store
      t.string :contact_note

      t.timestamps
    end
  end
end
