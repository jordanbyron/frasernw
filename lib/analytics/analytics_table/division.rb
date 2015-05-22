module Analytics
  module AnalyticsTable
    # Two dimensional table on user type and division
    # TODO: abstract to generic 2D table
    # this isn't really specific to analytics
    class Division < Base
      def user_type_divisions(key)
        search(user_type_key: key).reject do |row|
          row[:division_id] == nil
        end
      end

      def total
        search(user_type_key: nil, division_id: nil)
      end

      def total_for_user_type(key)
        search(user_type_key: key, division_id: nil)
      end

      def by_division
        search(user_type_key: nil).reject do |row|
          row[:division_id] == nil
        end
      end
    end
  end
end
