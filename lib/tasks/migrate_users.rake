namespace :pathways do
  namespace :migrate_users do

    task :division, [:division_id] => [:environment] do |t, args|
      division_id = args[:division_id] || -1
      if division_id == -1
        puts "Specify a division id with :division[division_id]"
        return
      end
      division = Division.find(Integer(division_id))
      puts "#{division.name}"

      specialist_users = Specialist.in_divisions(division).reject{ |s| s.divisions.length != 1 }.map{ |s| s.controlling_users }.flatten
      clinic_users = Clinic.in_divisions([division]).reject{ |c| c.divisions.length != 1 }.map{ |c| c.controlling_users }.flatten

      users = (specialist_users + clinic_users).uniq

      users.each do |user|
        if user.divisions.include? division
          puts "user #{user.name} is already in #{division.name}"
          next
        end

        if (user.controlled_specialists.reject{ |s| s.divisions.length == 1 }.length > 0)
          puts "user #{user.name} also has prividleges to edit a specialist outside of #{division.name}"
          next
        end

        if (user.controlled_clinics.reject{ |c| c.divisions.length == 1 }.length > 0)
          puts "user #{user.name} also has prividleges to edit a clinic outside of #{division.name}"
          next
        end

        user.user_divisions.each do |ud|
          puts "DELETING #{user.name} old division membership in: #{ud.division.name}"
          #remove the old division, if any
          DivisionUser.destroy(ud.id)
        end
        DivisionUser.create(:user_id => user.id, :division_id => division.id)

        puts "user #{user.name} - #{user.id} has been moved to #{division.name}"
      end
    end
  end
end
