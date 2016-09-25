module FeaturedContentsHelper
  def featured_contents_options(category, division)
    items = category.
      all_sc_items_in_divisions([division]).
      sort_by(&:title)

    [
      [ "--- NEW ---", items.select(&:new?) ],
      [ "-----------", items.reject(&:new?) ]
    ].select{|group| group[1].any? }
  end
end
