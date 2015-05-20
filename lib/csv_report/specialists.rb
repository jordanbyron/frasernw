module CSVReport
  class Specialists
    attr_reader :abstract

    def initialize(abstract_table)
      @abstract = abstract_table
    end

    def column_keys
      [:id, :favorites, specialty]
    end

    def exec
      [ header_row ] + body_rows
    end

    def header_row
      [
        "id",
        "favorites",
        "specialty"
      ]
    end

    def body_rows
      abstract.inject([]) do |body_rows, row|
        body_rows << column_keys.map do |key|
          row[key]
        end
      end
    end
  end
end
