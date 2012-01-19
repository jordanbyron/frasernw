class AdditionalDetailsIsText < ActiveRecord::Migration
  def change
    change_column(:specialists, :status_details, :text, :limit => nil)
  end
end
