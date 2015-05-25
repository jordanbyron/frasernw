module Analytics
  module Labeler
    class Resource
      # takes a set of records + path string to match, and produces labels from the path given to #exec

      attr_reader :records, :path_string

      def resources
        @resource ||= ScItem.all
      end

      def categories
        @categories ||= ScCategory.all
      end

      def id_regexp
        @id_regexp ||= /(?<=\/content_items\/)[[:digit:]]+/
      end

      def exec(page_path)
        item_id = page_path[id_regexp].to_i
        item = resource.find {|resource| resource.id == item_id }

        if item.nil?
          {
            resource: "Not found",
            category: "Not found"
          }
        else
          category = categories.find do |category|
            category.id == item.sc_category_id
          end

          {
            resource: item.name,
            category: category.name
          }
        end
      end
    end
  end
end
