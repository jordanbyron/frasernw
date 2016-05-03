module ProceduresHelper

  def procedure_ancestry_options_limited(items, skip_tree, &block)
    return procedure_ancestry_options_limited(items, skip_tree){ |i|
      "#{'-' * i.depth} #{i.procedure.name}"
    } unless block_given?

    result = []
    items.map do |item, sub_items|
      next if skip_tree and skip_tree.include? item
      next if not item.procedure
      result << [yield(item), item.id]
      result += procedure_ancestry_options_limited(sub_items, skip_tree, &block)
    end
    result
  end

end
