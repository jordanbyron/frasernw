namespace :pathways do
  task :division_survey_report, [:division_id] => :environment do |t, args|
    include Rails.application.routes.url_helpers

    args.with_defaults(
      division_id: 10
    )

    division = Division.find(args[:division_id])
    timestamp = DateTime.now.to_s.safe_for_filename
    folder_path =
      Rails.root.join('reports','division_records', timestamp).to_s

    table_headings = [
      "Pathways Id",
      "Name",
      "Contact Name",
      "Contact Phone",
      "Contact Email",
      "Controlling User #1 Name",
      "Controlling User #1 Email",
      "Controlling User #2 Name",
      "Controlling User #2 Email",
      "Controlling User #3 Name",
      "Controlling User #3 Email",
      "Controlling User #4 Name",
      "Controlling User #4 Email"
    ]
    generate_row = Proc.new do |record|
      [
        record.id,
        record.name,
        record.contact_name,
        record.contact_phone,
        record.contact_email,
        record.controlling_users[0].try(:name),
        record.controlling_users[0].try(:email),
        record.controlling_users[1].try(:name),
        record.controlling_users[1].try(:email),
        record.controlling_users[2].try(:name),
        record.controlling_users[2].try(:email),
        record.controlling_users[3].try(:name),
        record.controlling_users[3].try(:email)
      ]
    end

    division_specialists = Specialist.in_divisions(division)
    specialists_table_name = "#{division.name}_specialists_#{timestamp}"
    specialists_table = [
      [ specialists_table_name ],
      [ "" ]
    ] + Specialization.all.inject([]) do |memo, specialization|
      memo << [ "" ]
      memo << [ specialization.name ]
      memo << table_headings
      memo + specialization.filter_by_self(division_specialists).map do |specialist|
        generate_row.call(specialist)
      end
    end

    division_clinics = Clinic.in_divisions([division])
    clinics_table_name = "#{division.name}_clinics_#{timestamp}"
    clinics_table = [
      [ clinics_table_name ],
      [ "" ]
    ] + Specialization.all.inject([]) do |memo, specialization|
      memo << [ "" ]
      memo << [ specialization.name]
      memo << table_headings
      memo + specialization.filter_by_self(division_clinics).map do |clinic|
        generate_row.call(clinic)
      end
    end

    FileUtils.ensure_folder_exists folder_path
    CSVReport::Service.new(
      "#{folder_path}/#{specialists_table_name}.csv",
      specialists_table
    ).exec

    CSVReport::Service.new(
      "#{folder_path}/#{clinics_table_name}.csv",
      clinics_table
    ).exec
  end
end
