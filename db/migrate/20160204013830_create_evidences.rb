class CreateEvidences < ActiveRecord::Migration
  def change
    create_table :evidences do |t|
      t.string :level, null: false
      t.string :description

      t.timestamps
    end
  end
end
