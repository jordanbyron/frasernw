module Metrics
  class SpecialistMetrics
    def initialize(*args)
      options = args.extract_options!
      # options[] defines which table columns to use.
      # (all: true) uses all tables


      table = Array.new

      Clinic.includes([:specializations, :versions, :archived_feedback_items, :feedback_items]).all.each do |clinic|

        clinic_row = Hash.new
        clinic_row[:id]                  = clinic.id
        clinic_row[:name]                = clinic.name
        clinic_row[:specialty]           = clinic.specializations.select(:name)
        clinic_row[:division]            = clinic.divisions.map { |d| d.name  }
        clinic_row[:first_version]       = clinic.versions.last.created_at
        clinic_row[:last_version]        = clinic.versions.first.created_at
        clinic_row[:version_number]      = clinic.versions.count

        clinic_row[:feedback_items]      = clinic.archived_feedback_items + clinic.feedback_items
        clinic_row[:feedback_item_count] = (0 + clinic.archived_feedback_items.count + clinic.feedback_items.count)

        table << clinic_row
      end
      @table = table
    end

    def as_csv
      CSVReport::ConvertHashArray.new(self).exec
    end
  end
end