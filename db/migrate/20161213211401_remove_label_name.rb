class RemoveLabelName < ActiveRecord::Migration
  def up
    remove_column :specializations, :label_name
  end
end
