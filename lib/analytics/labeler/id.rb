module Analytics
  module Labeler
    class Id
      # takes a set of records, and produces labels from the id given to #exec
      attr_reader :records

      def initialize(records, options = {})
        @records = records
      end

      def key_to_match
        options[:key_to_match] || :id
      end

      def exec(id)
        record = records.find{ |record| record.send(key_to_match) == id.to_i }

        record.try(:name) || options[:fallback_message] || ""
      end
    end
  end
end
