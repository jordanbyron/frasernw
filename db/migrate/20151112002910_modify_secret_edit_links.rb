class ModifySecretEditLinks < ActiveRecord::Migration
  def up
    # create tokens

    create_table :secret_tokens do |t|
      t.integer :creator_id, null: false
      t.string :recipient, null: false
      t.integer :accessible_id, null: false
      t.string :accessible_type, null: false
      t.string :token, null: false
      t.boolean :expired, default: false, null: false

      t.timestamps
    end
    add_index :secret_tokens, [:accessible_id, :accessible_type], name: "secret_token_item"

    # allow us to make 'editor' polymorphic -- user or secret token
    rename_column :review_items, :whodunnit, :edit_source_id

    add_column :review_items, :edit_source_type, :string

    ReviewItem.where("edit_source_id IS NOT NULL").update_all(edit_source_type: "User")

    # allow us to record who edited the update that's being saved
    add_column :versions, :review_item_id, :integer

    # migrate existing tokens to new system

    [
      Specialist,
      Clinic
    ].each do |klass|
      klass.all.each do |record|
        SecretToken.create(
          accessible_type: klass.name,
          accessible_id: record.id,
          token: SecureRandom.hex(16),
          recipient: "Unknown (from previous system)",
          creator_id: 0
        )
      end
    end

    # generate new tokens

    [
      Specialist,
      Clinic
    ].each do |klass|
      klass.all.each do |record|
        record.update_attributes(secret_token: SecureRandom.hex(16))
      end
    end
  end

  def down
  end
end
