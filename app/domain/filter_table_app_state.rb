class FilterTableAppState < ServiceObject
  attribute :current_user, User

  def call
    {
      currentUser: CurrentUser.call(current_user: current_user),
      specializations: Denormalized.fetch(:specializations),
      contentCategories: Denormalized.fetch(:content_categories),
      contentItems: Denormalized.fetch(:content_items),
      cities: Denormalized.fetch(:cities),
      hospitals: Denormalized.fetch(:hospitals),
      procedures: Denormalized.fetch(:procedures),
      respondsWithinOptions: Denormalized.fetch(:respondsWithinOptions),
      respondsWithinSummaryLabels: Denormalized.fetch(:respondsWithinSummaryLabels),
      dayKeys: Schedule::DAY_HASH,
      languages: Denormalized.fetch(:languages),
      careProviders: Denormalized.fetch(:healthcare_providers),
      divisions: Denormalized.fetch(:divisions),
      referentStatusIcons: Specialist::STATUS_CLASS_HASH.invert,
      tooltips: {
        specialists: Specialist::STATUS_TOOLTIP_HASH.inject({}) do |memo, (k, v)|
          memo.merge(Specialist::STATUS_CLASS_HASH[k] => v)
        end,
        clinics: Clinic::STATUS_HASH.merge({
          0 => Clinic::UNKNOWN_STATUS,
          3 => Clinic::UNKNOWN_STATUS
        })
      },
      waittimeHash: Specialist::WAITTIME_LABELS,
      teleserviceFeeTypes: Teleservice::SERVICE_TYPES.map do |key, value|
        [ key, value.downcase ]
      end.to_h
    }
  end

  class CurrentUser < ServiceObject
    attribute :current_user, User

    def call
      {
        divisionIds: current_user.as_divisions.standard.map(&:id),
        cityRankings: current_user.city_rankings,
        cityRankingsCustomized: current_user.customized_city_rankings?,
        favorites: {
          contentItems: current_user.favorite_content_items.pluck(:id)
        },
        role: current_user.role
      }
    end
  end
end
