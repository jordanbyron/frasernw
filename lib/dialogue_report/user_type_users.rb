module DialogueReport
  # takes an abstract table (array of hashes) and writes it to a CSV
  # TODO extract common functionality to service superclass
  class UserTypeUsers
    attr_reader :options

    def initialize(options = {})
      @options = options.reverse_merge!(
        start_month: Month.new(2014, 1),
        end_month: Month.new(2014, 12),
        folder_path: Rails.root.join('reports', 'dialogue', 'latest').to_s
      )
    end

    def exec
      CSV.write_from_array(
        "#{options[:folder_path]}/user_type_users.csv",
        concrete
      )
    end

    def concrete
      @concrete ||= [ headings ] + body_rows
    end

    def abstract
      @abstract ||= Reporter::UserTypeUsers.time_series(
        options[:start_month],
        options[:end_month]
      )
    end

    def months
      @months ||= abstract.columns.select {|column| column.is_a? Month }
    end

    def headings
      ["User type", "Division"] + months.map(&:name)
    end

    def user_type_rows_sets
      abstract.rows.subsets{|row| row[:user_type_key] }
    end

    def body_rows
      user_type_rows_sets.inject([]) do |memo, row_set|
        memo + user_type_rows(row_set)
      end
    end

    def divisions
      @divisions ||= Division.all
    end

    def division_from_id(id)
      division = divisions.find {|division| division.id == id.to_i }

      if !division.nil?
        division.name
      else
        "No Division"
      end
    end

    def user_type_rows(abstract_user_type_rows)
      rows = []

      user_type = AnalyticsApiAdapter.user_type_from_key(
        abstract_user_type_rows.first[:user_type_key]
        )

      # Totals
      rows << [
        user_type,
        "All Divisions"
      ] + months.map {|month| Table.sum_column(abstract_user_type_rows, month)}

      # Breakdown by division
      abstract_user_type_rows.each do |division|
        rows << [
          "",
          division_from_id(division[:division_id])
        ] + months.map {|month| (division[month] || 0) }
      end

      rows
    end
  end
end
