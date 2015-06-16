module Analytics
  module Labeler
    class Path
      # takes a set of records + path string to match, and produces labels from the path given to #exec

      attr_reader :records, :path_string

      def initialize(records, path_string)
        @records = records
        @path_string = path_string
      end

      def id_regexp
        @id_regexp ||= /(?<=#{Regexp.quote(path_string)})[[:digit:]]+/
      end

      def exec(page_path)
        record_id = page_path[id_regexp].to_i

        record = records.find{ |record| record.id == record_id }

        record.try(:name) || ""
      end
    end
  end
end
