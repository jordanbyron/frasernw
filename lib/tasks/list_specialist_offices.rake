namespace :pathways do
  task :list_specialist_offices => :environment do
    Office.all.reject{ |o| o.num_specialists <= 1 || o.specialists.first.specializations.blank? }.sort{ |a,b| a.specialists.first.specializations.first.name <=> b.specialists.first.specializations.first.name }.each do |o|
      next if o.empty?
      puts o.short_address
      o.specialist_offices.reject{ |so| so.specialist.blank? }.each do |so|
        puts "#{so.specialist.name} (#{so.specialist.specializations.map{ |s| s.name }.to_sentence}) #{so.phone_and_fax}"
      end
      puts ""
      puts ""
    end  
  end
end