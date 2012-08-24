namespace :pathways do
  task :list_multiple_specialist_offices => :environment do
    Office.all.reject{ |o| o.num_specialists <= 1 }.sort{ |a,b| a.specialists.first.specializations.first.name <=> b.specialists.first.specializations.first.name }.each do |o|
    
      puts o.full_address
      o.controlling_users.uniq.each do |u|
        puts "Account name: #{u.name}"
        puts "Access key: #{u.token}"
        puts "Account is for:"
        u.controlled_specialist_offices.each do |so|
          next if so.specialist.blank?
          puts "- #{so.specialist.name} (#{so.specialist.specializations.map{ |s| s.name }.to_sentence}) #{so.phone_and_fax}"
        end
        puts ""
      end
      puts ""
      puts ""
    end  
  end
end