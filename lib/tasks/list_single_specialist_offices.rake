namespace :pathways do
  task :list_single_specialist_offices => :environment do
    Office.all.reject{ 
      |o| o.num_specialists != 1 || 
      o.specialists.first.specializations.blank? || 
      o.empty? || 
      !o.specialists.first.responded? || 
      o.specialists.first.retired? || 
      o.specialists.first.status_mask == 8 
    }.sort{ |a,b| a.specialists.first.specializations.first.owner.name + " " + a.specialists.first.specializations.first.name <=> b.specialists.first.specializations.first.owner.name + " " + b.specialists.first.specializations.first.name }.each do |o|
      puts "Assigned to #{o.specialists.first.specializations.first.owner.name}"
      o.specialist_offices.reject{ |so| so.specialist.blank? }.each do |so|
        puts "#{so.specialist.name} (#{so.specialist.specializations.map{ |s| s.name }.to_sentence}) #{so.phone_and_fax}"
        puts o.full_address
        puts so.specialist.status if so.specialist.retiring?
        puts "Senior MOA contact details: #{so.specialist.contact_name} #{so.specialist.contact_email} #{so.specialist.contact_phone} #{so.specialist.contact_notes}" if so.specialist.contact_name.present?
        puts "Account name: #{so.controlling_users.first.name}"
        puts "Access key: #{so.controlling_users.first.token}"
      end
      puts ""
      puts ""
    end  
  end
end