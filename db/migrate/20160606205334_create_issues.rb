class CreateIssues < ActiveRecord::Migration
  def up
    create_table :issues do |t|
      t.string :title
      t.text :description
      t.integer :progress_key, default: 1
      t.integer :source_key, default: 4
      t.integer :completion_estimate_key, default: 4
      t.string :priority, default: ""
      t.string :effort_estimate, default: "-"
      t.date :manual_date_entered
      t.date :manual_date_completed

      t.timestamps
    end

    create_table :issue_assignments do |t|
      t.integer :issue_id
      t.integer :assignee_id

      t.timestamps
    end

    add_column :users, :is_developer, :boolean, default: false

    User.
      where(name: ["Brian Gracie", "Daniel Musekamp"]).
      update_all(is_developer: true)
  end
end
