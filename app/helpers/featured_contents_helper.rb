module FeaturedContentsHelper
  def featured_contents_options(items)
    [
      ["NEW", items.select(&:new?)],
      ["Not New", items.reject(&:new?)]
    ].select{|option| option[1].any? }
  end

end
