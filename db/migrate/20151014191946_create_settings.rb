class CreateSettings < ActiveRecord::Migration
  def up
    create_table :settings do |t|
      t.integer :value, null: false
      t.integer :identifier, null: false

      t.timestamps
    end

    add_index :settings, [:identifier], name: "settings_identifier"

    Setting.create(identifier: 1, value: 1)
  end

  def down
    drop_table :settings
  end
end
