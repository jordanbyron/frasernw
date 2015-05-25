# takes an abstract table, applies any necessary filters to it, and outputs table in array format (which the csv service can handle)

module Analytics
  module CSVPresenter
    class Base

      def initialize(options)
        @options = options
      end

      def date_options
        options.slice(:start_month, :end_month)
      end

      def metric
        options[:metric]
      end

      def title
        options[:title]
      end

      def months
        @months ||= Month.for_interval(
          options[:start_month],
          options[:end_month]
        )
      end

      def filters
        []
      end

      def filtered
        filters.inject(abstract) do |memo, filter|
          filter.exec(memo)
        end
      end

      def user_type_labeler
        @user_type_labeler ||= Analytics::Labeler::UserType.new
      end
    end
  end
end