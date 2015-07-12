class AddContentOwnerToSpecializationOptions < ActiveRecord::Migration
  def change
    add_column :specialization_options, :content_owner_id, :integer

    SpecializationOption.all.each do |so|
      so.content_owner_id = 3 #ron warneboldt
      so.save
    end
  end
end
