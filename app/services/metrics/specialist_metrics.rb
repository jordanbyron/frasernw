#e.g. Metrics::SpecialistMetrics.new(all: true,
#   folder_path: "reports/dialogue/").to_csv_file

module Metrics
  class SpecialistMetrics

    attr_accessor :table
    attr_reader   :folder_path

    def initialize(*args)
      options = args.extract_options!
      # options[] defines which table columns to use.
      # (all: true) uses all tables
      @folder_path = options[:folder_path]
      table = []
      Specialist.
        includes( [
          :specializations,
          :favorites,
          :versions,
          :archived_feedback_items,
          :feedback_items
        ] ).
        each do |specialist|
          specialist_row = Hash.new
          if ((options[:all] || options[:favorites]) == true)
            specialist_row[:favorites] = specialist.favorites.count
          end
          if ((options[:all] || options[:id]) == true)
            specialist_row[:specialist_id] = specialist.id
          end
          if ((options[:all] || options[:status]) == true)
            specialist_row[:status] = specialist.status
          end
          if ((options[:all] || options[:specialty]) == true)
            specialist_row[:specialty] =
              specialist.specializations.map{|s| s.name}.join(",")
          end
          if ((options[:all] || options[:specialty_count]) == true)
            specialist_row[:specialty_count] =
              specialist.specialist_specializations.count
          end
          if ((options[:all] || options[:division]) == true)
            specialist_row[:division] =
              specialist.divisions.map { |d| d.name  }.join(",")
          end
          if ((options[:all] || options[:division_count]) == true)
            specialist_row[:division_count] = specialist.divisions.count
          end
          if ((options[:all] || options[:first_version]) == true)
            specialist_row[:first_version] = specialist.versions.last.created_at
          end
          if ((options[:all] || options[:last_version]) == true)
            specialist_row[:last_version] = specialist.versions.first.created_at
          end
          if ((options[:all] || options[:version_number]) == true)
            specialist_row[:version_number] = specialist.versions.count
          end
          table << specialist_row
        end
      @table = table
    end

    def as_csv
      CSVReport::ConvertHashArray.new(self.table).exec
    end

    def to_csv_file
      CSVReport::Service.new(
        "#{folder_path}/specialist_metrics-#{DateTime.now.to_date.iso8601}.csv",
        self.as_csv
      ).exec
    end
  end
end
