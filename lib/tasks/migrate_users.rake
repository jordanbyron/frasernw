namespace :pathways do
  namespace :migrate_users do
    
    task :division, [:division_id] => [:environment] do |t, args|
      division_id = args[:division_id] || -1
      if division_id == -1
        puts "Specify a division id with :division[division_id]"
        return
      end
      division = Division.find(Integer(division_id))
      puts "Division #{division.name}"
      
      specialist_users = Specialist.in_divisions([division]).reject{ |s| s.divisions.length != 1 }.map{ |s| s.controlling_users }.flatten.uniq
      clinic_users = Clinic.in_divisions([division]).reject{ |c| c.divisions.length != 1 }.map{ |c| c.controlling_users }.flatten.uniq
      
      users = specialist_users + clinic_users
      
      users.each do |user|
        next if user.divisions.include? division
        
        if user.divisions.length <= 1
          user.user_divisions.each do |ud|
            #remove the old division, if any
            DivisionUser.destroy(ud.id)
          end
          DivisionUser.create(:user_id => user.id, :division_id => division.id)
          puts "user #{user.name} has been moved"
        else
          DivisionUser.create(:user_id => user.id, :division_id => division.id)
          puts "user #{user.name} has been added to division"
        end
      end
    end
  end
end