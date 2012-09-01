namespace :pathways do
  task :create_multiple_specialist_access_keys => :environment do
    Office.all.reject{ |o| o.num_specialists <= 1 || o.specialists.reject{ |s| !s.responded? || s.retired? || s.status_mask == 8 }.blank?
    }.each do |o|
      specialist_last_names = o.specialists.map{ |s| s.lastname }
      user = User.new :name => "Drs. #{specialist_last_names.to_sentence}'s Office", :type_mask => 2, :role => 'user'
      user.save :validate => false
      
      o.specialist_offices.reject{ |so| so.specialist.blank? }.each do |so|
        user_controls_specialist_office = user.user_controls_specialist_offices.build :specialist_office_id => so.id
        user_controls_specialist_office.save
      end
    end  
  end
end