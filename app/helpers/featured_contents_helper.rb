module FeaturedContentsHelper
  def featured_contents_options(category, division)
    category.
      all_sc_items_in_divisions([division]).
      sort_by{|item| [ (item.new? ? 0 : 1), item.title ] }
  end
end
