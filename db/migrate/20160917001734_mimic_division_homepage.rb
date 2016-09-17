class MimicDivisionHomepage < ActiveRecord::Migration
  def up
    add_column :divisions, :use_other_homepage, :boolean
    add_column :divisions, :custom_homepage_as_id, :integer
  end
end
