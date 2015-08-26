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
      }
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
    ]
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
