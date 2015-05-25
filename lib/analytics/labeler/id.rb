module Analytics
  module Labeler
    class Id
      # takes a set of records, and produces labels from the id given to #exec

      attr_reader :records

      def initialize(records, not_found_message="")
        @records = records
      end

      def exec(id)
        record = records.find{ |record| record.id == id.to_i }

        record.try(:name) || not_found_message
      end
    end
  end
end
