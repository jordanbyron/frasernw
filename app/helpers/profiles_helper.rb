module ProfilesHelper
  def filter_profiles(specialization, profiles)
    profiles.select do |profile|
      profile.specializations.include?(specialization)
    end
  end
end
