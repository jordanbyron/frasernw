class CreateMetrics < ActiveRecord::Migration
  def up
    create_table :metrics, force: true do |t|
      t.integer :month_stamp, null: false
      t.integer :division_id, default: nil
      t.string  :page_path, default: nil
      t.integer :user_type_key, default: nil
      t.integer :sessions
      t.integer :page_views
      t.integer :visitor_accounts_min5sessions
      t.integer :visitor_accounts_min10sessions
      t.integer :visitor_accounts
      t.integer :average_session_duration
      t.integer :average_page_view_duration
    end

    add_index :metrics, [:user_type_key, :division_id, :page_path], name: "metrics_dimensions"
  end

  def down
    drop_table :metrics
  end
end
