module Analytics
  module Labeler
    class Resource
      # takes a set of records + path string to match, and produces labels from the path given to #exec

      def id_regexp
        @id_regexp ||= /(?<=\/content_items\/)[[:digit:]]+/
      end

      def exec(page_path)
        item_id = page_path[id_regexp].to_i
        item = ScItem.where(id: item_id).first

        if item.nil?
          {
            resource: "Not found",
            category: "Not found"
          }
        else
          {
            resource: item.label,
            category: item.sc_category.try(:name)
          }
        end
      end
    end
  end
end
