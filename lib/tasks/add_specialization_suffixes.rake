namespace :pathways do
  task :add_specialization_suffixes => :environment do
    s1 = Specialization.find_by_name("Family Practice")
    s1.suffix = "GP"
    s1.save!

    s2 = Specialization.find_by_name("Internal Medicine")
    s2.suffix = "Int Med"
    s2.save!

    s3 = Specialization.find_by_name("Midwifery")
    s3.suffix = "Midwife"
    s3.save!

    s4 = Specialization.find_by_name("Nurse Practitioner")
    s4.suffix = "Nurse"
    s4.save!
  end
end