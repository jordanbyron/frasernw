module Analytics
  # parses options fed to frame module to construct a query
  module Query
    class Base
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def exec
        query = {
          metrics: [ metric ],
          dimensions: dimensions,
        }.merge(date_options)

        puts "querying for #{query}"
        query
      end

      def date_options
        options.slice(:start_date, :end_date)
      end

      def dimensions
        raise NotImplementedError
      end

      def metric
        raise NotImplementedError
      end
    end
  end
end
