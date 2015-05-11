class AddAdminToSpecializations < ActiveRecord::Migration
  def change
    create_table :specialization_owners do |t|
      t.integer :specialization_id
      t.integer :owner_id

      t.timestamps
    end

    owner_map = {
      "Addiction Medicine" => 11,
      "Allergy" => 7,
      "Cardiology" => 7,
      "Cardiothoracic Surgery" => 11,
      "Dermatology" => 7,
      "ENT / Otolaryngology" => 11,
      "Endocrinology" => 11,
      "Gastroenterology" => 7,
      "General Surgery" => 11,
      "Geriatrics" => 7,
      "Hematology / Oncology" => 11,
      "Infectious Disease" => 7,
      "Internal Medicine" => 11,
      "Nephrology" => 11,
      "Neurology" => 7,
      "Neurosurgery" => 11,
      "Obstetrics / Gynecology" => 11,
      "Ophthalmology" => 7,
      "Orthopedics" => 11,
      "Pain Management" => 7,
      "Palliative Care" => 7,
      "Pediatrics" => 7,
      "Plastic Surgery" => 11,
      "Psychiatry" => 11,
      "Rehabilitation Medicine" => 11,
      "Respirology" => 11,
      "Rheumatology" => 11,
      "Sports Medicine" => 7,
      "Urology" => 7,
      "Vascular Surgery" => 11
    }

    owner_map.each do |specialization_name, user_id|
      specialization_id = Specialization.find_by_name(specialization_name).id
      specialization_owner = SpecializationOwner.new
      specialization_owner.specialization_id = specialization_id
      specialization_owner.owner_id = user_id
      specialization_owner.save
    end
  end
end
