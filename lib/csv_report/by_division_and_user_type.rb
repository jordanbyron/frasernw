module CSVReport
  # gets an abstract table (array of hashes) and converts it to an array of arrays, a format the CSV service can handle
  class ByDivisionAndUserType
    def self.exec(abstract, title)
      new(abstract, title).exec
    end

    attr_reader :abstract, :title

    def initialize(abstract, title="users")
      @abstract, @title = abstract, title
    end

    def exec
      headings + by_user_type + by_division
    end

    def headings
      [
        [ title ],
        (["User type", "Division"] + months.map(&:name))
      ]
    end

    def by_user_type
      abstract_by_user_type.inject([]) do |memo, abstract_for_user_type|
        memo + rows_for_user_type(abstract_for_user_type)
      end
    end

    def by_division
      rows = []

      rows << ([
        "All User Types",
        "All Divisions"
      ] + months.map {|month| Table.sum_column(abstract.rows, month)})

      rows + abstract_by_division.inject([]) do |memo, division|
        memo << ([
          "",
          division_from_id(division.first[:division_id])
        ] + months.map {|month| Table.sum_column(division, month)})
      end
    end

    def months
      @months ||= abstract.columns.select {|column| column.is_a? Month }
    end

    def abstract_by_user_type
      abstract.rows.subsets{|row| row[:user_type_key] }
    end

    def abstract_by_division
      abstract.rows.subsets{|row| row[:division_id] }
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

    def rows_for_user_type(abstract_for_user_type)
      rows = []

      user_type = AnalyticsApiAdapter.user_type_from_key(
        abstract_for_user_type.first[:user_type_key]
      )

      # Totals
      rows << [
        user_type,
        "All Divisions"
      ] + months.map {|month| Table.sum_column(abstract_for_user_type, month)}

      # Breakdown by division
      abstract_for_user_type.each do |division|
        rows << [
          "",
          division_from_id(division[:division_id])
        ] + months.map {|month| (division[month] || 0) }
      end

      rows
    end
  end
end
