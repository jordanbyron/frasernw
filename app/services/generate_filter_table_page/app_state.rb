class GenerateFilterTablePage
  class AppState
    include ServiceObject.exec_with_args(:user, :specialization)

    def exec
      {
        currentUser: {
          divisionIds: user.divisions.map(&:id),
          cityRankings: user.city_rankings,
          favorites: {
            contentItems: user.favorite_content_items.pluck(:id)
          },
          isAdmin: user.admin?,
          referralCities: {
            specialization.id => user.divisions_referral_cities(specialization).reject(&:hidden).map(&:id)
          },
          openToPanel: {
            specialization.id => open_to_panel
          }
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
        nestedProcedureIds: Serialized::BySpecialization.fetch(:nested_procedure_ids, specialization),
        languages: Serialized.fetch(:languages),
        careProviders: Serialized.fetch(:healthcare_providers)
      }
    end

    private

    def open_to_panel
      specialization_option = specialization.
        specialization_options.
        to_a.
        find do |option|
          option.division_id == user.divisions.first.id
        end

      if specialization_option.open_to_sc_category?
        {
          type: "contentCategories",
          id: specialization_option.open_to
        }
      else
        {
          type: specialization_option.open_to
        }
      end
    end
  end
end
