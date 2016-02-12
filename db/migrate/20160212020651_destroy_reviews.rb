class DestroyReviews < ActiveRecord::Migration
  def up
    drop_table :reviews
  end

  def down
  end
end
