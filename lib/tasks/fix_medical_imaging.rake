namespace :pathways do
  task :fix_medical_imaging => :environment do

    medical_imaging_specialization_id = 48
    
    mammography_procedure_id = 1034
    mammography_data = [[242, nil, nil, ""], [244, 1, nil, ""], [253, 1, nil, "Send any previous mammograms prior to appointment."], [238, nil, nil, ""], [250, 2, 2, ""], [254, 2, 2, ""], [258, nil, nil, ""], [256, 2, 3, ""], [255, 4, nil, ""], [274, nil, nil, ""], [287, nil, nil, ""], [285, 3, nil, ""]]

    data = { mammography_procedure_id => mammography_data }
    
    data.each do |procedure_id, procedure_data|
    
      procedure_specialization = ProcedureSpecialization.find_by_specialization_id_and_procedure_id(medical_imaging_specialization_id, procedure_id)
      
      if procedure_specialization == nil
        puts "procedure_specialization is nil" 
        next
      end
      
      procedure_data.each do |entry|
        clinic_id = entry[0];
        wait_time = entry[1];
        lag_time = entry[2];
        investigation = entry[3];
        
        focus = Focus.new(:clinic_id => clinic_id, :waittime_mask => wait_time, :lagtime_mask => lag_time, :investigation => investigation)
        
        procedure_specialization.focuses << focus
        
      end
      
      procedure_specialization.save

    end

    puts "done recovery."
  end
end