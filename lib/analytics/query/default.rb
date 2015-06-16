module Analytics
  module Query
    class Default < Base
      def metric
        options[:metric]
      end

      def dimensions
        options[:dimensions]
      end
    end
  end
end
