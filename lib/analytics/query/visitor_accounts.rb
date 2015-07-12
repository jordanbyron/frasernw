module Analytics
  module Query
    class VisitorAccounts < Base
      # http://www.analyticsedge.com/2014/09/misunderstood-metrics-sessions-pages/

      def metric
        if options[:dimensions].include? :page_path
          :page_views
        else
          :sessions
        end
      end

      def dimensions
        [ options[:dimensions], :user_id ].flatten
      end
    end
  end
end
