class DropReports < ActiveRecord::Migration
  def up
    drop_table :reports
  end

  def down
    create_table :reports do |t|
      t.string  :name
      t.integer :type_mask
      t.integer :level_mask
      t.integer :division_id
      t.integer :city_id
      t.integer :user_type_mask
      t.integer :time_frame_mask
      t.date    :start_date, default: nil
      t.date    :end_date, default: nil
      t.boolean :by_user, default: false
      t.boolean :by_pageview, default: false
      t.boolean :only_shared_care, default: false

      t.timestamps
    end
  end
end
