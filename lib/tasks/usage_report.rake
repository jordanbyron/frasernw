require 'csv'



namespace :pathways do
  task :sept_2015_usage_report do
    months = [
      ["{2015-3-1}","{2015-3-31}"],
      ["{2015-4-1}","{2015-4-30}"],
      ["{2015-5-1}","{2015-5-31}"],
      ["{2015-6-1}","{2015-6-30}"],
      ["{2015-7-1}","{2015-7-31}"],
      ["{2015-8-1}","{2015-8-31}"]
    ]

    months.each do |month|
      Rake::Task["pathways:usage_report"].reenable
      Rake::Task["pathways:usage_report"].invoke(*month)
    end

    Division.pluck(:id).reject{ |elem| elem == 13 || elem == 11 }.each do |division_id|
      months.each do |month|
        Rake::Task["pathways:usage_report"].reenable
        Rake::Task["pathways:usage_report"].invoke(*[ month, division_id ].flatten)
      end
    end
  end

  task :usage_report, [:start_date, :end_date, :division_id] => :environment do |t, args|

    ### Parse args

    start_date = Date.strptime(args[:start_date], "{%Y-%m-%d}")
    end_date = Date.strptime(args[:end_date], "{%Y-%m-%d}")
    division = Division.where(id: args[:division_id]).first

    ### Create the CSV

    csv_array = UsageReport.exec(
      start_date: start_date,
      end_date: end_date,
      division: Division.where(id: division_id).first
    )

    ### Write it

    timestamp = DateTime.now.strftime("%Y-%m-%d-%H:%M")
    filename  = [
      "pathways_usage_report",
      (division.try(:name) || "(global"),
      "g@#{timestamp}",
      "s@#{start_date.strftime("%Y-%m-%d")}",
      "e@#{end_date.strftime("%Y-%m-%d")}"
    ].join("_").safe_for_filename + ".csv"

    folder_path = Rails.root.join("reports", "usage")
    FileUtils.ensure_folder_exists folder_path
    file_path = folder_path.join(filename)

    CSV.write_from_array(file_path, csv_array)
  end
end
