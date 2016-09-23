class MimicDivisionHomepage < ActiveRecord::Migration
  def up
    add_column :divisions, :use_other_homepage, :boolean
    add_column :divisions, :other_homepage_as_id, :integer
  end
end
