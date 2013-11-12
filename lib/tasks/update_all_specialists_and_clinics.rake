namespace :pathways do
  task :update_all_specialists_and_clinics => :environment do
    Specialist.all.each do |s|
      next if s.review_object.present?
      puts "#{s.name}"
      a = Mechanize.new
      a.get("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/temp_edit") do |specialist_edit_page|
        specialist_edit_page.forms.first.submit
      end
    end

    Clinic.all.each do |c|
      next if c.review_object.present?
      puts "#{c.name}"
      a = Mechanize.new
      a.get("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/temp_edit") do |clinic_edit_page|
        clinic_edit_page.forms.first.submit
      end
    end
  end
end