class MigrateUsersControl < ActiveRecord::Migration
  def up
    ## Setup Sanity Check
    # before = User.all.inject({}) do |memo, user|
    #   memo.merge({
    #     user.id => {
    #       :specialists => (user.controlled_specialist_offices.map(&:specialist).map(&:id) + user.user_controls_specialists.map(&:specialist_id)).uniq.sort.select{|id| Specialist.exists?(id: id)},
    #       :clinics => (user.controlled_clinic_locations.map(&:clinic).map(&:id) + user.user_controls_clinics.map(&:clinic_id)).uniq.sort.select{|id| Clinic.exists?(id: id) }
    #     }
    #   })
    # end

    User.all.each do |user|
      user.controlled_specialist_offices.each do |specialist_office|
        user.user_controls_specialists.create(specialist_id: specialist_office.specialist.id)
      end

      user.controlled_clinic_locations.each do |clinic_location|
        user.user_controls_clinics.create(clinic_id: clinic_location.clinic.id)
      end

      # cleanup dupes
      user.reload.user_controls_specialists.group_by(&:specialist_id).each do |id, ucss|
        ucss.drop(1).map(&:destroy)
      end

      user.reload.user_controls_clinics.group_by(&:clinic_id).each do |id, uccs|
        uccs.drop(1).map(&:destroy)
      end

      # get rid of joins for dead clinics and specialists

      user.reload.user_controls_clinics.reject{|ucc| Clinic.exists?(id: ucc.clinic_id) }.map(&:destroy)
      user.reload.user_controls_specialists.reject{|ucs| Specialist.exists?(id: ucs.specialist_id) }.map(&:destroy)
    end

    ## Sanity Check
    # before.each do |id, controlled_profiles|
    #   user = User.find(id).reload
    #
    #   unless controlled_profiles[:specialists] == user.controlled_specialists.map(&:id).sort
    #     raise "user: #{user.id}, old specialists: #{controlled_profiles[:specialists]}, new specialists: #{user.controlled_specialists.map(&:id).sort}"
    #   end
    #
    #   unless controlled_profiles[:clinics] == user.controlled_clinics.map(&:id).sort
    #     raise "user: #{user.id}, old clinics: #{controlled_profiles[:clinics]}, new clinics: #{user.controlled_clinics.map(&:id).sort}"
    #   end
    # end
  end

  def down
  end
end
