class CourtesyMailer < ActionMailer::Base
  default from: "noreply@pathwaysbc.ca"

  def availability_update(user_id, specialist_id)
    @user = User.find(user_id)
    @specialist = Specialist.find(specialist_id)

    mail(
      to: @user.email,
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: Peroid of unavailability ended [Availability Update]"
    )
  end

  def extrajurisdictional_edit_update(
    owner_id,
    owner_division_id,
    user_id,
    editor_id,
    linked_entity_klassname,
    linked_entity_id
  )
    @owner_division = Division.find(owner_division_id)
    @owner = User.find(owner_id)
    @linked_entity_klass = linked_entity_klassname.constantize
    @linked_entity = @linked_entity_klass.find(linked_entity_id)
    @editor = User.find(editor_id)
    @linked_entity_path = send(
      "#{@linked_entity_klass.downcase.singularize}_url",
      @linked_entity
    )

    mail(
      to: @owner.email,
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: Someone from outside #{@owner_division.name} "\
        "created a record in your division [New Record Update]"
    )
  end

end
