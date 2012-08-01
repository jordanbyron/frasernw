namespace :pathways do
  task :list_specialist_offices => :environment do
    Office.all.sort{ |a,b| a.num_specialists <=> b.num_specialists }.each do |o|
      next if o.num_specialists == 0
      next if o.empty?
      puts o.short_address
      o.specialist_offices.reject{ |so| so.specialist.blank? }.each do |so|
        puts "#{so.specialist.name} #{so.phone_and_fax}"
      end
      puts ""
      puts ""
    end  
  end
end