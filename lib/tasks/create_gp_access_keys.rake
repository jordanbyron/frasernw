namespace :pathways do
  task :create_gp_access_keys => :environment do
    # # # # # # # # # #
    # THIS RAKE TASK IS DEPRECATED/OLD/OUTDATED, IGNORE DO NOT USE/RUN!
    # # # # # # # # # #
    gp_list = ""
    while (x = STDIN.gets) do
      gp_list += x.chomp
    end
    gp_list = gp_list.split('|')
    gp_list = gp_list.map{|gp| gp.split(',')}

    gp_hash = {}

    gp_list.each do |gp|

      key = gp[5] #address grouping
      key = "h" + key if gp[0] == "Hospitalist"
      key = "l" + key if gp[0] == "Locum"
      key = "r" + key if gp[0] == "Resident"
      key = "o" + key if gp[0] == "Other"
      name = gp[2].blank? ? gp[1] : gp[2][0...1] + ". " + gp[1]
      gp_hash[key] ? gp_hash[key] << name : gp_hash[key] = [name]

    end

    gp_hash.each do |key, names|

      hospitalist = key[0...1] == "h"
      locum = key[0...1] == "l"
      resident = key[0...1] == "r"
      other = key[0...1] == "o"

      type_mask = 1
      type_mask = 5 if hospitalist
      type_mask = 6 if locum
      type_mask = 7 if resident
      type_mask = 4 if other

      user_name = (hospitalist || locum || resident) ? "Dr. #{names.to_sentence}" : (other ? names.to_sentence : "Dr. #{names.to_sentence}'s Office")
      user = User.new :name => user_name, :type_mask => type_mask, :role => 'user'
      user.save :validate => false
      puts "Created #{user_name}"

    end

  end
end