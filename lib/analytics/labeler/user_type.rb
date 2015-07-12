module Analytics
  module Labeler
    class UserType
      def exec(user_type_key)
        Analytics::ApiAdapter.user_type_hash[user_type_key.to_i]
      end
    end
  end
end
