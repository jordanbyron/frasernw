namespace :pathways do
  task :list_procedures => :environment do
    Specialization.all.each do |s|
      puts "#{s.name}: focused" if s.procedure_specializations.focused.length > 0
      s.focused_procedure_specializations_arranged.each do |ps, children|
        if ps.procedure.specializations.length > 1
          puts "- #{ps.procedure.name} (shared between #{ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
        else
          puts "- #{ps.procedure.name}"
        end
        children.each do |child_ps, grandchildren|
          if child_ps.procedure.specializations.length > 1
            puts "-- #{child_ps.procedure.name} (shared between #{child_ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
          else
              puts "-- #{child_ps.procedure.name}"
          end
          grandchildren.each do |grandchild_ps, greatgrandchildren|
            if grandchild_ps.procedure.specializations.length > 1
              puts "--- #{grandchild_ps.procedure.name} (shared between #{grandchild_ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
            else
                puts "--- #{grandchild_ps.procedure.name}"
            end
          end
        end
      end
      puts "" if s.procedure_specializations.non_focused.length > 0
      puts "#{s.name}: non focused" if s.procedure_specializations.non_focused.length > 0
      s.non_focused_procedure_specializations_arranged.each do |ps, children|
        if ps.procedure.specializations.length > 1
          puts "- #{ps.procedure.name} (shared between #{ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
        else
          puts "- #{ps.procedure.name}"
        end
        children.each do |child_ps, grandchildren|
          if child_ps.procedure.specializations.length > 1
            puts "-- #{child_ps.procedure.name} (shared between #{child_ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
          else
              puts "-- #{child_ps.procedure.name}"
          end
          grandchildren.each do |grandchild_ps, greatgrandchildren|
            if grandchild_ps.procedure.specializations.length > 1
              puts "--- #{grandchild_ps.procedure.name} (shared between #{grandchild_ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
            else
                puts "--- #{grandchild_ps.procedure.name}"
            end
          end
        end
      end
      puts "" if s.procedure_specializations.assumed_specialist.length > 0
      puts "#{s.name}: assumed specialist" if s.procedure_specializations.assumed_specialist.length > 0
      s.assumed_specialist_procedure_specializations_arranged.each do |ps, children|
        if ps.procedure.specializations.length > 1
          puts "- #{ps.procedure.name} (shared between #{ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
        else
          puts "- #{ps.procedure.name}"
        end
        children.each do |child_ps, grandchildren|
          if child_ps.procedure.specializations.length > 1
            puts "-- #{child_ps.procedure.name} (shared between #{child_ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
          else
              puts "-- #{child_ps.procedure.name}"
          end
          grandchildren.each do |grandchild_ps, greatgrandchildren|
            if grandchild_ps.procedure.specializations.length > 1
              puts "--- #{grandchild_ps.procedure.name} (shared between #{grandchild_ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
            else
                puts "--- #{grandchild_ps.procedure.name}"
            end
          end
        end
      end
      puts "" if s.procedure_specializations.assumed_clinic.length > 0
      puts "#{s.name}: assumed clinic" if s.procedure_specializations.assumed_specialist.length > 0
      s.assumed_clinic_procedure_specializations_arranged.each do |ps, children|
        if ps.procedure.specializations.length > 1
          puts "- #{ps.procedure.name} (shared between #{ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
        else
          puts "- #{ps.procedure.name}"
        end
        children.each do |child_ps, grandchildren|
          if child_ps.procedure.specializations.length > 1
            puts "-- #{child_ps.procedure.name} (shared between #{child_ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
          else
              puts "-- #{child_ps.procedure.name}"
          end
          grandchildren.each do |grandchild_ps, greatgrandchildren|
            if grandchild_ps.procedure.specializations.length > 1
              puts "--- #{grandchild_ps.procedure.name} (shared between #{grandchild_ps.procedure.specializations.map{ |specializations| specializations.name }.to_sentence})"
            else
                puts "--- #{grandchild_ps.procedure.name}"
            end
          end
        end
      end
      puts ""
      puts ""
    end  
  end
end