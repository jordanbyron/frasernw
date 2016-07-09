namespace :pathways do
  task fix_medical_imaging: :environment do

    medical_imaging_specialization_id = 48

    mammography_procedure_id = 1034
    mammography_data = [
      [242, nil, nil, ""],
      [244, 1, nil, ""],
      [253, 1, nil, "Send any previous mammograms prior to appointment."],
      [238, nil, nil, ""],
      [250, 2, 2, ""],
      [254, 2, 2, ""],
      [258, nil, nil, ""],
      [256, 2, 3, ""],
      [255, 4, nil, ""],
      [274, nil, nil, ""],
      [287, nil, nil, ""],
      [285, 3, nil, ""]
    ]

    screening_procedure_id = 862
    screening_data = [
      [250, nil, nil, "Can often offer same day service."],
      [253, nil, nil, "Limited - see comments below."],
      [256, nil, nil, ""],
      [274, nil, nil, ""],
      [287, nil, nil, ""]
    ]

    diagnostic_procedure_id = 863
    diagnostic_data = [
      [242, nil, nil, ""],
      [244, nil, nil, ""],
      [238, nil, nil, ""],
      [253, nil, nil, ""],
      [
        250,
        nil,
        nil,
        "Offer diagnostic mammo through medical imaging or through the "\
          "Breast Health Clinic."
      ],
      [254, nil, nil, ""],
      [255, nil, nil, ""],
      [285, nil, nil, ""]
    ]

    guided_biopsy_procedure_id = 871
    guided_biopsy_data = [
      [242, nil, nil, ""],
      [250, nil, nil, ""],
      [238, nil, nil, ""],
      [254, nil, nil, ""],
      [285, nil, nil, ""]
    ]

    adult_radiology_procedure_id = 1035
    adult_radiology_data = [
      [238, nil, nil, ""],
      [242, nil, nil, ""],
      [249, nil, nil, ""],
      [244, nil, nil, ""],
      [248, nil, nil, ""],
      [250, nil, nil, ""],
      [253, nil, nil, ""],
      [254, nil, nil, ""],
      [255, nil, nil, ""],
      [256, nil, nil, ""],
      [258, nil, nil, ""],
      [273, nil, nil, ""],
      [285, nil, nil, ""],
      [286, nil, nil, ""]
    ]

    data = {
      mammography_procedure_id => mammography_data,
      screening_procedure_id => screening_data,
      diagnostic_procedure_id => diagnostic_data,
      guided_biopsy_procedure_id => guided_biopsy_data,
      adult_radiology_procedure_id => adult_radiology_data
    }

    data.each do |procedure_id, procedure_data|

      procedure_specialization = ProcedureSpecialization.find_by(
        specialization_id: medical_imaging_specialization_id,
        procedure_id: procedure_id
      )

      puts "#{procedure_specialization.procedure.name}"

      if procedure_specialization == nil
        puts "procedure_specialization is nil"
        next
      end

      procedure_data.each do |entry|
        clinic_id = entry[0];
        wait_time = entry[1];
        lag_time = entry[2];
        investigation = entry[3];

        puts "#{Clinic.find(clinic_id).name}"

        clinic_area_of_practice = ClinicAreaOfPractice.new(
          clinic_id: clinic_id,
          waittime_mask: wait_time,
          lagtime_mask: lag_time,
          investigation: investigation
        )

        procedure_specialization.clinic_areas_of_practice << clinic_area_of_practice

      end

      procedure_specialization.save

    end

    puts "done recovery."
  end
end
