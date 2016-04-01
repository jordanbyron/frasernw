task remove_vancouver_hidden: :environment do
  vancouver_hidden_division = Division.find(11)

  clinics_approved_for_deletion = [
    592,
    487,
    657,
    433,
    624,
    573,
    649,
    557,
    566,
    669,
    632,
    563,
    587,
    662,
    527,
    663,
    626,
    590,
    451,
    610,
    533,
    515,
    516,
    530,
    531,
    656,
    532,
    528,
    613,
    482,
    486
  ]

  vancouver_hidden_clinics = Clinic.
    in_divisions([vancouver_hidden_division]).
    map(&:id)

  clinics_not_approved_for_deletion =
    vancouver_hidden_clinics - clinics_approved_for_deletion

  puts "Clinics in Vancouver (hidden) not approved for deletion: #{clinics_not_approved_for_deletion}"

  Clinic.where(id: clinics_approved_for_deletion).each do |clinic|
    if clinic.divisions.map(&:id) == [ 11 ]
      clinic.destroy
    else
      puts "Didn't delete clinic #{clinic.id} because it is also in other divisions"
    end
  end

  hospitals_approved_for_deletion = [
    57,
    50,
    53,
    48,
    54,
    58,
    51,
    49,
    52,
    55,
    47
  ]

  vancouver_hidden_hospitals = Hospital.
    in_divisions([vancouver_hidden_division]).
    map(&:id)

  hospitals_not_approved_for_deletion =
    vancouver_hidden_hospitals - hospitals_approved_for_deletion

  puts "Hospitals in Vancouver (hidden) not approved for deletion: #{hospitals_not_approved_for_deletion}"

  Hospital.where(id: hospitals_approved_for_deletion).each do |hospital|
    if hospital.divisions.map(&:id) == [ 11 ]
      hospital.destroy
    else
      puts "Didn't delete hospital #{hospital.id} because it is also in other divisions"
    end
  end

  City.where(name: "Vancouver (Hidden)").destroy_all

  vancouver_hidden_division.destroy
end
