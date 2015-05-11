class AddConsultsToSpecialists < ActiveRecord::Migration
  def change

    items = Array.new(28) { Hash.new }

    #Addiction medicine
    items[0]['s'] = '23'
    items[0]['o'] = '244'
    items[0]['h'] = '245'

    #Allergy
    items[1]['s'] = '28'
    items[1]['o'] = '286'
    items[1]['h'] = '287'

    #Cardiology
    items[2]['s'] = '4'
    items[2]['o'] = '294'
    items[2]['h'] = '295'

    #Cardiothoracic Surgery
    items[3]['s'] = '25'
    items[3]['o'] = '258'
    items[3]['h'] = '259'

    #Dermatology
    items[4]['s'] = '5'
    items[4]['o'] = '300'
    items[4]['h'] = '325'

    #ENT
    items[5]['s'] = '18'
    items[5]['o'] = '193'
    items[5]['h'] = '194'

    #Endocrinology
    items[6]['s'] = '6'
    items[6]['o'] = '242'
    items[6]['h'] = '243'

    #Gastroenterology
    items[7]['s'] = '8'
    items[7]['o'] = '298'
    items[7]['h'] = '299'

    #General Surgery
    items[8]['s'] = '3'
    items[8]['o'] = '352'
    items[8]['h'] = '353'

    #Geriatrics
    items[9]['s'] = '7'
    items[9]['o'] = '304'
    items[9]['h'] = '305'

    #Hematology / Oncology
    items[10]['s'] = '27'
    items[10]['o'] = '273'
    items[10]['h'] = '274'

    #Infectious Disease
    items[11]['s'] = '34'
    items[11]['o'] = '375'
    items[11]['h'] = '376'

    #Nephrology
    items[12]['s'] = '17'
    items[12]['o'] = '186'
    items[12]['h'] = '187'

    #Neurology
    items[13]['s'] = '14'
    items[13]['o'] = '134'
    items[13]['h'] = '135'

    #Neurosurgery
    items[14]['s'] = '20'
    items[14]['o'] = '260'
    items[14]['h'] = '261'

    #OB/GYN
    items[15]['s'] = '22'
    items[15]['o'] = '262'
    items[15]['h'] = '263'

    #Ophthamology
    items[16]['s'] = '15'
    items[16]['o'] = '308'
    items[16]['h'] = '309'

    #Orthopedics
    items[17]['s'] = '1'
    items[17]['o'] = '370'
    items[17]['h'] = '371'

    #Pain Management
    items[18]['s'] = '30'
    items[18]['o'] = '333'
    items[18]['h'] = '334'

    #Pediatrics
    items[19]['s'] = '31'
    items[19]['o'] = '343'
    items[19]['h'] = '344'

    #Plastic Surgery
    items[20]['s'] = '10'
    items[20]['o'] = '312'
    items[20]['h'] = '313'

    #Psychiatry
    items[21]['s'] = '35'
    items[21]['o'] = '384'
    items[21]['h'] = '383'

    #Rehabilitation Medicine
    items[22]['s'] = '29'
    items[22]['o'] = '322'
    items[22]['h'] = '323'

    #Respirology
    items[23]['s'] = '2'
    items[23]['o'] = '264'
    items[23]['h'] = '265'

    #Rheumatology
    items[24]['s'] = '9'
    items[24]['o'] = '267'
    items[24]['h'] = '268'

    #Sports Medicine
    items[25]['s'] = '32'
    items[25]['o'] = '346'
    items[25]['h'] = '347'

    #Urology
    items[26]['s'] = '33'
    items[26]['o'] = '361'
    items[26]['h'] = '362'

    #Vascular Surgery
    items[27]['s'] = '26'
    items[27]['o'] = '282'
    items[27]['h'] = '283'

    items.each do |item|
      s_id = item['s']
      o_id = item['o']
      h_id = item['h']

      ps_office = ProcedureSpecialization.find_by_procedure_id_and_specialization_id(o_id, s_id)
      ps_hospital = ProcedureSpecialization.find_by_procedure_id_and_specialization_id(h_id, s_id)
      s = Specialization.find(s_id)

      say("Adding #{ps_office.procedure.name} and #{ps_hospital.procedure.name} to specialists in #{s.name}")

      #make the office procedures focused in this specialization
      ps_office.classification = ProcedureSpecialization::CLASSIFICATION_FOCUSED
      ps_office.save

      #make the hospital procedures focused in this specialization
      ps_hospital.classification = ProcedureSpecialization::CLASSIFICATION_FOCUSED
      ps_hospital.save

      s.specialists.each do |sp|
        #make specialists do office procedures if they have an office
        Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(sp.id, ps_office.id) if sp.specialist_offices.reject{ |so| so.empty? }.length > 0

        #make specialist do hospital procedures if they have hospital priviledges. Decided this was a bad assumption.
        #Capacity.find_or_create_by_specialist_id_and_procedure_specialization_id(sp.id, ps_hospital.id) if sp.hospitals.length > 0
      end
    end

  end
end
