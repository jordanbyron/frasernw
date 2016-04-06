task vancouver_hidden_report: :environment do

  # dependent destroys:
  # division_cities: just a join table
  # division_referral_cities: has city priority; presumably transferred
  # division_referral_city_specializations: has local referral area for division; presumably trasnfered
  # division_users: just a join table
  # division_display_sc_items: borrowed sc items join table; presumably transferred
  # subscription_divisions: just a join table, shouldn't be transferred
  # featured_contents: just a join table; presumably transferred
  # division_primary_contacts: just a join table; presumably transferred
  # specialization_options: just a join table specifying options for specialty pages; presumably transferred

  vancouver_hidden_division = Division.find(11)
  vancouver_division = Division.find(10)

  # loosely linked

  cities = {
    title: "Cities",
    header_row: ["Id", "Name"],
    body_rows: vancouver_hidden_division.cities.map{ |city| [ city.id, city.name ] }
  }

  users = {
    title: "Users",
    header_row: ["Id", "Name"],
    body_rows: vancouver_hidden_division.users.map{ |user| [ user.id, user.name ] }
  }

  clinics = {
    title: "Clinics",
    header_row: [
      "Id",
      "Name",
      "ID for Matching Vancouver Division Clinic",
      "Division ID's",
      "ID's for Specialists With Offices In",
      "ID's for Attending Specialists"
    ],
    body_rows: Clinic.in_divisions([vancouver_hidden_division]).map do |clinic|
      [
        clinic.id,
        clinic.name,
        Clinic.where("name = (?) AND id != (?)", clinic.name, clinic.id).select{|clinic| clinic.divisions.include?(vancouver_division) }.first.try(:id),
        clinic.divisions.map(&:id).to_s,
        clinic.specialists_with_offices_in.map(&:id).to_s,
        clinic.specialists.map(&:id).to_s
      ]
    end
  }

  specialists = {
    title: "Specialists",
    header_row: ["Id", "Name"],
    body_rows: Specialist.in_divisions(vancouver_hidden_division).map do |specialist|
      [
        specialist.id,
        specialist.name
      ]
    end
  }

  hospitals = {
    title: "Hospitals",
    header_row: [
      "Id",
      "Name",
      "ID for Matching Vancouver Division Hospital",
      "Division ID's",
      "ID's for Clinics In",
      "Clinics Only In Vancouver (Hidden)",
      "ID's for Specialist With Offices In",
      "ID's for Specialists with Privileges"
    ],
    body_rows: Hospital.in_divisions([vancouver_hidden_division]).map do |hospital|
      [
        hospital.id,
        hospital.name,
        Hospital.where("name = (?) AND id != (?)", hospital.name, hospital.id).select{|hospital| hospital.divisions.include?(vancouver_division) }.first.try(:id),
        hospital.divisions.map(&:id).to_s,
        hospital.clinics_in.map(&:id).to_s,
        [[11], []].include?(hospital.clinics_in.map(&:divisions).flatten.uniq.map(&:id)),
        hospital.direct_offices_in.map(&:specialist_office).reject(&:nil?).map(&:specialist).map(&:id).to_s,
        hospital.specialists.map(&:id).to_s
      ]
    end
  }

  owned_sc_items = {
    title: "Owned Content Items",
    header_row: [
      "Id",
      "Name",
    ],
    body_rows: vancouver_hidden_division.sc_items.map do |item|
      [
        item.id,
        item.name
      ]
    end
  }

  QuickSpreadsheet.call(
    sheets: [
      clinics,
      hospitals,
      specialists,
      users,
      cities,
      owned_sc_items
    ],
    filename: "vancouver_hidden_report_g#{Time.now.strftime("%Y-%m-%d-%H.%M")}"
  )
end
