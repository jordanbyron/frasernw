namespace :pathways do
  task :create_single_specialist_access_keys => :environment do
    # # # # # # # # # #
    # THIS RAKE TASK IS DEPRECATED/OLD/OUTDATED, IGNORE DO NOT USE/RUN!
    # # # # # # # # # #
    Office.all.reject{
      |o| o.num_specialists != 1 ||
      o.specialists.first.specializations.blank? ||
      o.empty? ||
      !o.specialists.first.responded? ||
      o.specialists.first.retired? ||
      o.specialists.first.status_mask == 8
    }.each do |o|
      o.specialist_offices.reject{ |so| so.specialist.blank? }.each do |so|
        specialist = so.specialist
        office = so.office

        user_controls_specialist_office = UserControlsSpecialistOffice.find_by_specialist_office_id so.id

        if user_controls_specialist_office.blank?
          #make account
          user = User.new :name => "#{specialist.formal_name}'s Office", :type_mask => 2, :role => 'user'
          user.save :validate => false
          user_controls_specialist_office = user.user_controls_specialist_offices.build :specialist_office_id => so.id
          user_controls_specialist_office.save
        else
          puts "#{specialist.name} in office #{office.short_address} is already controlled by #{user_controls_specialist_office.user.name}"
        end
      end
    end
  end
end