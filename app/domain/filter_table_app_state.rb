class FilterTableAppState
  include ServiceObject.exec_with_args(:current_user)

  def exec
    {
      currentUser: {
        divisionIds: current_user.divisions.map(&:id),
        cityRankings: current_user.city_rankings,
        favorites: {
          contentItems: current_user.favorite_content_items.pluck(:id)
        },
        isAdmin: current_user.admin?
      },
      specializations: Serialized.fetch(:specializations),
      contentCategories: Serialized.fetch(:content_categories),
      contentItems: Serialized.fetch(:content_items),
      cities: Serialized.fetch(:cities),
      hospitals: Serialized.fetch(:hospitals),
      procedures: Serialized.fetch(:procedures),
      respondsWithinOptions: Serialized.fetch(:respondsWithinOptions),
      respondsWithinSummaryLabels: Serialized.fetch(:respondsWithinSummaryLabels),
      dayKeys: Schedule::DAY_HASH,
      languages: Serialized.fetch(:languages),
      careProviders: Serialized.fetch(:healthcare_providers),
      divisions: Serialized.fetch(:divisions),
      referentStatusIcons: Specialist::STATUS_CLASS_HASH.invert
    }
  end
end
