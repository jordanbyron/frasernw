task remove_vancouver_hidden: :environment do
  vancouver_hidden_division = Division.find(11)

  vancouver_hidden_division.cities.destroy_all
  Specialist.in_division([vancouver_hidden_division]).destroy_all
  Clinic.in_division([vancouver_hidden_division]).destroy_all
  Hospital.in_division([vancouver_hidden_division]).destroy_all

  vancouver_hidden_division.destroy
end
