class CreateIssues < ActiveRecord::Migration
  def up
    create_table :issues do |t|
      t.text :description
      t.integer :progress_key
      t.integer :source_key
      t.integer :completion_estimate_key
      t.integer :priority_key
      t.date :manual_date_entered

      t.timestamps
    end

    create_table :developers do |t|
      t.integer :user_id
    end
  end
end
