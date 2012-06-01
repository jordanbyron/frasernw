class AddMemberNameToSpecializations < ActiveRecord::Migration
  def change
    add_column :specializations, :member_name, :string
    
    Specialization.reset_column_information
    
    member_name_mappings = {
      "Addiction Medicine" => "Addiction medicine specialist",
      "Allergy" => "Allergist",
      "Cardiology" => "Cariodologist",
      "Cardiothoracic Surgery" => "Cardiothoracic surgeon",
      "Dermatology" => "Dermatologist",
      "ENT (Otolaryngology)" => "Otolaryngologist",
      "Endocrinology" => "Endocrinologist",
      "Gastroenterology" => "Gastroenterologist",
      "General Surgery" => "General surgeon",
      "Geriatrics" => "Geriatrician",
      "Hematology/Oncology" => "Hematologist/oncologist",
      "Infectious Disease" => "Infectious disease specialist",
      "Internal Medicine" => "Internal medicine specialist",
      "Nephrology" => "Nephrologist",
      "Neurology" => "Neurologist",
      "Neurosurgery" => "Neurosurgeon",
      "Obstetrics Gynecology" => "Obstetrician/gynecologist",
      "Ophthalmology" => "Ophthalmologist",
      "Orthopedics" => "Orthopedic surgeon",
      "Pain Management" => "Pain management specialist",
      "Pediatrics" => "Pediatrician",
      "Plastic Surgery" => "Plastic surgeon",
      "Psychiatry" => "Psychiatrist",
      "Rehabilitation Medicine" => "Rehabilitation medicine specialist",
      "Respirology" => "Respirologist",
      "Rheumatology" => "Rheumatologist",
      "Sports Medicine" => "Sports medicine specialist",
      "Urology" => "Urologist",
      "Vascular Surgery" => "Vascular surgeon"
    }
    
    member_name_mappings.each do |specialization_name, specialization_member_name|
      s = Specialization.find_by_name(specialization_name)
      puts "!!!!!!!!!!!!!!!!!! Can't find #{specialization_name}" if s.blank?
      next if s.blank?
      s.member_name = specialization_member_name
      s.save
    end
    
    missing_member_names = Specialization.all.reject{ |s| s.member_name.present? }
    
    puts "!!!!!!!!!!!!!!!!!! #{missing_member_names.map{|s| s.name}.to_sentence} are missing member names" if missing_member_names.length != 0
  end
end
