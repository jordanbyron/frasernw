module Denormalized
  class CurrentUser < ServiceObject

    attribute :current_user, User

    def call
      if current_user.authenticated?
        {
          id: current_user.id,
          divisionIds: current_user.as_divisions.map(&:id),
          cityRankings: current_user.city_rankings,
          cityRankingsCustomized: current_user.customized_city_rankings?,
          favorites: {
            contentItems: current_user.favorite_content_items.pluck(:id)
          },
          role: current_user.as_role,
          adjustedTypeMask: current_user.adjusted_type_mask
        }
      else
        {
          role: current_user.role
        }
      end
    end
  end
end
