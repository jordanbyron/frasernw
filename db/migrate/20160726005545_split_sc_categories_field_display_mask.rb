class SplitScCategoriesFieldDisplayMask < ActiveRecord::Migration
  def change
    add_column :sc_categories, :index_display_format, :integer, default: 0
    add_column :sc_categories, :in_global_navigation, :boolean, default: false
    add_column :sc_categories, :filterable, :boolean, default: false
    ScCategory.reset_column_information

    ScCategory.all.each do |category|
      case category.display_mask
        when 1 # "Filterable on specialty pages"
          category.update_attributes!(filterable: true)
        when 2 # "In global navigation"
          category.update_attributes!(in_global_navigation: true)
        when 3 # "Inline on specialty pages"
          category.update_attributes!(index_display_format: 1)
        when 4 # "In global navigation and filterable on specialty pages"
          category.update_attributes!(
            in_global_navigation: true, filterable: true
          )
        when 5 # "In global navigation and inline on specialty pages"
          category.update_attributes!(
            index_display_format: 1, in_global_navigation: true
          )
      end
    end
    ScCategory.where(name: "Pearls").first.update!(filterable: true)

    remove_column :sc_categories, :display_mask
    remove_column :sc_categories, :show_as_dropdown
  end
end
