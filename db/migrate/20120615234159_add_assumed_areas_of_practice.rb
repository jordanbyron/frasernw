class AddAssumedAreasOfPractice < ActiveRecord::Migration
  def change
    input = {
      "Addiction Medicine" => ["alcohol withdrawal", "drug withdrawal", "methadone treatment", "drug counseling"],

      "Allergy" => ["skin testing", "desensitization"],

      "Cardiology" => ["arrhythmia", "valvular heart disease", "cardiac stress test", "hypertension", "angina", "congestive heart failure", "coronary heart disease", "chest pain", "hyperlipidemia", "myocardial infarction", "cardiomyopathy", "syncope", "peripheral vascular disease", "atrial fibrillaton", "acute coronary syndrome", "primary prevention", "secondary prevention", "dyslipidemia"],

      "Cardiothoracic Surgery" => ["mediastinal mass", "lung cancer", "empyema", "lung abscess", "coronary artery disease", "valvular heart disease", "critical care"],

      "Dermatology" => ["skin ulcer", "rash", "pruritis", "skin allergy", "atopic dermatitis", "acne", "rosacea", "skin lesion", "psoriasis", "skin cancer", "exzema", "seborrheic dermatitis", "skin infections", "pemphigus", "vesicles", "bullae", "drug rash", "erythema multiforme", "alopecia"],

      "Endocrinology" => ["thyroid disease", "hypothyroidism", "hyperthyroidism", "hyperparathyroidism", "adrenal disease", "Addison's disease", "diabetes", "pituitary disease", "pituitary adenoma", "dyslipidemia", "obesity", "Cushing's disease", "hirsuitism", "pheochromocytoma", "hypercalcemia", "osteoporosis", "paget's disease", "hyperlipidemia"],

      "ENT / Otolaryngology" => ["hoarseness", "hearing loss", "tinnitus", "perforated ear drum", "serous otitis", "chronic otitis", "mastoiditis", "sinusitis", "rhinitis", "mouth lesions", "salivary gland disease", " sialadenitis", "ENT cancers", "nasal obstruction"],

      "Gastroenterology" => ["GI bleed", "peptic ulcer disease", "functional dyspepsia", "colitis", "Irritable bowel syndrome", "Crohn's disease", " ulcerative colitis", "abdominal pain", "constipation", "diarrhea", "jaundice", "esophagitis", "GERD", "celiac disease", "malabsorption", "pancreatitis", "gastrointestinal cancers", "sigmiodoscopy", "hepatitis"],

      "General Surgery" => ["acute abdomen", "bowel obstruction", "bowel cancer", "colon cancer", "pilonidal sinus", "ileostomy", "colostomy", "cholecystitis", "cholelithiasis", "biliary cholic", "obstructive jaundice", "breast cancer", "breast lump"],

      "Geriatrics" => ["frailty", "falls", "delirium", "caregiver stress", "abuse", "dementia", "neurodegenerative disease", "failure to thrive", "weight loss", "polypharmacy", "depression", "anxiety", "urinary incontinence"],

      "Hematology / Oncology" => ["anemia", "polycythemia", "hemoglobinopathy", " haemoglobinopathy", "hemolytic anemia", "hemochromotosis", "haemochromotosis", "coagulopathy"],

      "Infectious Disease" => ["septicemia", "tuberculosis", "herpes infections", "endocarditis", "chronic infections", "cellulites", "meningitis", "HIV", "fever of unknown origin", "hepatitis"],

      "Internal Medicine" => ["arrhythmia", "valvular heart disease", "hypertension", "angina", "congestive heart failure", "coronary heart disease", "chest pain", "hyperlipidemia", "myocardial infarction", "cardiomyopathy", "syncope", "peripheral vascular disease", "atrial fibrillaton", "primary prevention", "secondary prevention", "dyslipidemia", "thyroid disease", "hypothyroidism", "hyperthyroidism", "hyperparathyroidism", "adrenal disease", "Addison's disease", "diabetes", "pituitary disease", "obesity", "Cushing's disease", "hirsuitism", "pheochromocytoma", "hypercalcemia", "osteoporosis", "paget's disease", "GI bleed", "peptic ulcer disease", "functional dyspepsia", "colitis", "irritable bowel syndrome", "Crohn's disease", " ulcerative colitis", "abdominal pain", "constipation", "diarrhea", "jaundice", "esophagitis", "GERD", "celiac disease", "malabsorption", "pancreatitis", "gastrointestinal cancers", "hepatitis", "abdominal cancers", "frailty", "falls", "delirium", "caregiver stress", "abuse", "dementia", "neurodegenerative disease", "failure to thrive", "weight loss", "polypharmacy", "depression", "anxiety", "urinary incontinence", "renal failure", "kidney cancers", "proteinuria", "hematuria", "glomerulonephritis", "nephropathy", "renal cystic disease", "shortness of breath", "cough", "asthma", "COPD", "cystic fibrosis", "interstitial lung disease", "pulmonary vascular disease", "lung infections", "lung abscess", "respiratory failure", "lung cancer", "pulmonary embolism", "pleurisy", "pleural effusion", "hemoptysis", "tuberculosis", "pheumothorax", "respiratory problems in neuromuscular disease", "concussion", "headache", "seizure", "neuropathy", "coma", "ataxia", "peripheral neuropathy", "myasthenia gravis", "myositis", "stroke", "TIA", "meningitis", "encephalitis", "epilepsy", "neuromuscular disease", "trigeminal neuralgia", "diplopia", "spasticity", "vertigo", "connective tissue disease", "rheumatoid arthritis", "vasculitis", "osteoarthritis", "gout", "pseudogout", "inflammatory arthritis", "septic arthritis", "soft tissue inflammation", "musculoskeletal pain", "fibromyalgia", "polymyalgia rheumatica", "pre-op assessments"],

      "Nephrology" => ["renal dialysis", "renal failure", "kidney cancers", "proteinuria", "hematuria", "glomerulonephritis", "nephropathy", "renal cystic disease"],

      "Neurology" => ["concussion", "headache", "seizure", "dementia", "neuropathy", "coma", "ataxia", "peripheral neuropathy", "myasthenia gravis", "myositis", "stroke", "TIA", "meningitis", "encephalitis", "epilepsy", "neuromuscular disease", "trigeminal neuralgia", "diplopia", "spasticity", "spinal cord disease", "vertigo", "visual field defect", "neuromyelitis optica"],

      "Neurosurgery" => ["space occupying lesion", "hydrocephalus", "penetrating skull wounds", "VP shunt", "increased intracranial pressure", "intracranial mass", "subarachnoid hemorrhage", "intracerebral hemorrhage", "intracranial aneurysm", "brain trauma"],

      "Obstetrics / Gynecology" => ["caesarian section", "gestational diabetes", "antenatal hemorrhage", "abnormal labour", "retained placenta", "vaginal discharge", "vaginitis", "vaginismus", "prolapse", "cystocele", "enterocele", "amenorrhea", "polycystic ovarian syndrome", " menorrhagia", "dysmenorrhea", "pelvic mass", "menopause", "and cancer of uterus", "ovary", "cervix", "vagina", "or vulva"],

      "Ophthalmology" => ["cataracts", "visual loss", "retinal disease", "conjunctivitis", "iritis", "corneal ulcers", "glaucoma", "blepharitis", "ptosis", "blepharitis", "pterygium", "scleritis", "corneal abrasion", "macular degeneration"],

      "Orthopedics" => ["fracture", "ligament injury", "tendonitis", "tendon injury", "septic arthritis", "joint pain", "bone cancer", "soft tissue injuries", "overuse syndromes"],

      "Pediatrics" => ["prematurity", "failure to thrive", "infant feeding problems", "congenital disease", "genetic disease", " child abuse", "adolescent medicine", "eneuresis", "encopresis", "language delay", "developmental delay", "children's asthma", "weight loss", "chronic diarrhea", "recurrent vomiting", "rash"],

      "Plastic Surgery" => ["skin cancer", "scar revision", "burns", "facial fractures", "cleft lip", "cleft palate"],

      "Rehabilitation Medicine" => ["stroke", "aphasia", "post-MVA", "disability"],

      "Respirology" => ["shortness of breath", "cough", "asthma", "COPD", "cystic fibrosis", "interstitial lung disease", "pulmonary vascular disease", "lung infections", "lung abscess", "respiratory failure", "lung cancer", "bronchoscopy", "pulmonary embolism", "pleurisy", "pleural effusion", "hemoptysis", "tuberculosis", "pheumothorax", "respiratory problems in neuromuscular disease"],

      "Rheumatology" => ["connective tissue disease", "rheumatoid arthritis", "vasculitis", "osteoarthritis", "gout", "pseudogout", "inflammatory arthritis", "septic arthritis", "soft tissue inflammation", "musculoskeletal pain", "fibromyalgia", "polymyalgia rheumatica"],

      "Sports Medicine" => ["soft tissue injuries", "repetitive strain", "tendonitis"],

      "Urology" => ["cystoscopy", "urological cancer", "bladder cancer", "prostate cancer", "hematuria", "renal colic", "recurrent urinary tract infections", "prostatitis", "epididymitis", "interstitial cystitis", "hydronephrosis", "erectile dysfunction testicular torsion", "spermatocele", "varicocele", "urethral syndrome", "infertility", "urilolithiasis"],

      "Vascular Surgery" => ["claudication", "vascular insufficiency", "diabetic vascular disease", "peripheral vascular disease", "aortic aneurysm"]
    }

    input.each do |specialization_name, procedure_names|
      s = Specialization.find_by_name(specialization_name)

      puts "Specialization #{specialization_name} not found!" if s.blank?

      procedure_names.each do | procedure_name |

        procedure_name = procedure_name.strip.capitalize

        p = Procedure.find_by_name(procedure_name)

        if p.present?

          #already exists

          if p.specializations.reject{ |specialization| s.id != specialization.id }.blank?

            #but not in this speciality. add it, and make it assumed
            ps = ProcedureSpecialization.new
            ps.specialization = s
            ps.procedure = p
            ps.classification = ProcedureSpecialization::CLASSIFICATION_ASSUMED
            ps.mapped = true
            ps.save

          elsif !ProcedureSpecialization.find_by(procedure_id: p.id, specialization_id: s.id).assumed?

            #hmm....
            puts "#{procedure_name} already exists in #{specialization_name} but it isn't assumed"

          else

            #exists and is assumed
            next

          end

          else

          #doesn't exist, make both the procedure and the 'assumed' link to the specialization
          p = Procedure.new

          ps = ProcedureSpecialization.new
          ps.specialization = s
          ps.procedure = p
          ps.classification = ProcedureSpecialization::CLASSIFICATION_ASSUMED
          ps.mapped = true
          ps.save

          p.name = procedure_name
          p.save

        end
      end
    end
  end
end
