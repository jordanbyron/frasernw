namespace :pathways do
  task :list_multiple_specialist_offices => :environment do
    Office.all.reject{ |o| o.num_specialists <= 1 }.sort{ |a,b| a.specialists.first.specializations.first.name <=> b.specialists.first.specializations.first.name }.each do |o|
    
      puts o.full_address
      puts ""
      o.controlling_users.uniq.each do |u|
        puts "Account name: #{u.name}"
        if u.pending?
          puts "Access key: #{u.token}"
        else
          puts "No access key needed, this account has previously been created and in use"
        end
        
        same_owner = (u.controlled_specialists.map{ |s| s.owner }.uniq.length == 1)
        
        if same_owner
          puts "Assigned to #{u.controlled_specialists.first.owner.name}"
        end
        
        puts "Account is for:"
        u.controlled_specialist_offices.each do |so|
          next if so.specialist.blank?
          if same_owner
            puts "- #{so.specialist.name} (#{so.specialist.specializations.map{ |s| s.name }.to_sentence}) #{so.phone_and_fax}"
          else
            puts "- #{so.specialist.name} (#{so.specialist.specializations.map{ |s| s.name }.to_sentence} - #{so.specialist.owner.name}) #{so.phone_and_fax}"
          end
        end
        puts ""
      end
      puts ""
      puts "--------------------------------------------------------"
      puts ""
    end  
  end
end