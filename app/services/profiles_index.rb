class ProfilesIndex < ServiceObject
  attribute :params
  attribute :klass
  attribute :current_user

  def call
    {
      profiles: profiles,
      label: label,
      generic_label: klass.to_s.pluralize,
      specialization: specialization,
      specializations: specializations,
      divisions_profiles: divisions_profiles,
      no_division_profiles: profiles.no_division,
      user_as_divisions: current_user.as_divisions.to_a
    }
  end

  def specialization
    @specialization ||=
      if params[:specialization_id ]
        Specialization.
          includes(:hidden_divisions).
          find(params[:specialization_id])
      end
  end

  def divisions_profiles
    Division.all.map do |division|
      division_profiles = profiles.in_divisions([division])

      [
        division,
        division_profiles
      ]
    end.to_h
  end

  def specializations
    @specializations ||=
      if params[:specialization_id]
        [ specialization]
      else
        Specialization.all.includes(:hidden_divisions)
      end
  end

  def label
    if klass == Specialist
      params[:specialization_id] ? specialization.member_name.pluralize : "Specialists"
    else
      "#{params[:specialization_id] ? (specialization.name + " ") : "" } Clinics"
    end
  end

  def profiles
    @profiles ||= begin
      if params[:specialization_id]
        scope = specialization.send(klass.to_s.tableize)
      else
        scope = klass
      end

      scope = scope.includes(:specializations)

      if params[:hidden]
        scope = scope.hidden
      end

      scope
    end
  end
end
