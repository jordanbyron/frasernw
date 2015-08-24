class GenerateSpecializationPage
  include ServiceObject.exec_with_args(:specialization_id)

  def exec
    @init_data = {
      selectedPanel: "specialists",
      panelNav: panel_nav,
      globalData: GlobalData.exec(specialization: specialization),
      panels: {
        specialists: Specialists.exec(
          specialization: specialization,
          referent_common_config: referent_common_config
        ),
        clinics: Clinics.exec(
          specialization: specialization,
          referent_common_config: referent_common_config
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

  def referent_common_config
    @referent_common_config = Referents.exec(specialization: specialization)
  end

  def specialization
    @specialization ||= Specialization.find(specialization_id)
  end
end
