module ScCategoriesHelper

  def ancestry_options_limited(items, skip_tree, &block)
    return ancestry_options_limited(items, skip_tree) do |i|
      "#{'-' * i.depth} #{i.name}"
    end unless block_given?

    result = []
    items.map do |item, sub_items|
      next if skip_tree and skip_tree.include? item
      result << [yield(item), item.id]
      result += ancestry_options_limited(sub_items, skip_tree, &block)
    end
    result
  end

end
