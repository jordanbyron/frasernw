# E.g.:  Metrics::ClinicMetrics.new(all: true, folder_path: "reports/dialogue/").to_csv_file

module Metrics
  class ClinicMetrics
    attr_accessor :table
    attr_reader   :folder_path

    def initialize(*args)
      options = args.extract_options!
      # options[] defines which table columns to use.
      # (all: true) uses all tables
      @folder_path = options[:folder_path]
      table = Array.new

      Clinic.includes([:specializations, :versions, :archived_feedback_items, :feedback_items]).all.each do |clinic|

        clinic_row = Hash.new
        clinic_row[:id]                  = clinic.id
        # clinic_row[:name]                = clinic.name
        clinic_row[:status]              = clinic.status
        clinic_row[:specialty]           = clinic.specializations.map{|s| s.name}.join(",")
        clinic_row[:division]            = clinic.divisions.map { |d| d.name  }.join(",")
        clinic_row[:first_version]       = clinic.versions.last.created_at
        clinic_row[:last_version]        = clinic.versions.first.created_at
        clinic_row[:version_number]      = clinic.versions.count

        # clinic_row[:feedback_items]      =  ( clinic.active_feedback_items +
        #                                       clinic.feedback_items).
        #                                       map { |f| f.feedback  }.join("  <<<< >>>>  ")
        # clinic_row[:feedback_item_count] = (0 + clinic.feedback_items.count + clinic.active_feedback_items.count)

        table << clinic_row
      end
      @table = table
    end

    def as_csv
      CSVReport::ConvertHashArray.new(self.table).exec
    end

    def to_csv_file
      CSVReport::Service.new("#{folder_path}/clinic_metrics-#{DateTime.now.to_date.iso8601}.csv", self.as_csv).exec
    end
  end
end