class GenerateFilterTablePage
  include ServiceObject.exec_with_args(
    :specialization_id,
    :current_user
  )

  def exec
    {
      app: AppState.exec(
        user: current_user,
        specialization: specialization
      ),
      ui: {
        specializationId: specialization.id,
        hasBeenInitialized: false
      }
    }
  end

  def specialization
    @specialization ||= Specialization.find(specialization_id)
  end
end
