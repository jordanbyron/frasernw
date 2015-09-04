class GenerateSpecializationPage
  include ServiceObject.exec_with_args(
    :specialization_id,
    :current_user
  )

  def exec
    {
      selectedPanel: "specialists",
      panelNav: panel_nav,
      globalData: GlobalData.exec(specialization: specialization),
      panels: {
        specialists: Specialists.exec(
          specialization: specialization,
          referral_cities: referral_cities
        ),
        clinics: Clinics.exec(
          specialization: specialization,
          referral_cities: referral_cities
        )
      }.merge(content_category_panels)
    }
  end

  private

  # order of and labels for panels
  def panel_nav
    [
      {
        key: "specialists",
        label: "Specialists"
      },
      {
        key: "clinics",
        label: "Clinics"
      }
    ] + content_categories.map do |category|
      {
        key: "CC_#{category[:category].id}",
        label: category[:category].name
      }
    end
  end

  def content_categories
    @content_categories ||= ScCategory.specialty.map do |category|
      {
        category: category,
        items: category.all_sc_items_for_specialization_in_divisions(
          specialization,
          current_user.divisions
        )
      }
    end.select{|category| category[:items].any?}
  end

  def content_category_panels
    content_categories.inject({}) do |memo, category|
      memo.merge({
        "CC_#{category[:category].id}" => ContentCategory.exec(
          specialization: specialization,
          category: category[:category],
          items: category[:items]
        )
      })
    end
  end

  def referral_cities
    current_user.divisions_referral_cities(
      specialization
    )
  end

  def specialization
    @specialization ||= Specialization.find(specialization_id)
  end
end
