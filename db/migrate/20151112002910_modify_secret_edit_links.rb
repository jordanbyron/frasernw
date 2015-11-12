class ModifySecretEditLinks < ActiveRecord::Migration
  def up
    # create tokens

    create_table :secret_tokens do |t|
      t.integer :creator_id, null: false
      t.string :recipient, null: false
      t.integer :accessible_id, null: false
      t.string :accessible_type, null: false
      t.string :token, null: false

      t.timestamps
    end
    add_index :secret_tokens, [:accessible_id, :accessible_type], name: "secret_token_item"

    # allow us to associate versions with them

    add_column :versions, :secret_token_id, :integer

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
          recipient: "Various",
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
