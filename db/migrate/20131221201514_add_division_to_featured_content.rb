class AddDivisionToFeaturedContent < ActiveRecord::Migration
  def change
    add_column :featured_contents, :division_id, :integer
    
    division = Division.find(1)
    
    FeaturedContent.all.each do |fc|
      fc.division_id = division
      fc.save
    end
  end
end
