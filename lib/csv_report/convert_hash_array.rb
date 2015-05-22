module CSVReport
  class ConvertHashArray
    # # Converts Hash Arrays
    # [ [:id => 3, :name => 'john'], [:id => 5, :name => 'joe'], [:id => 6, :name => 'karen'] ...]

    # # To CSV:
    # id,name
    # 3,john
    # 5,joe
    # 6,Karen

    # # Usage
    # Creates a CSV ready object:  CSVReport::ConvertHashArray.new(table).exec
    attr_reader :abstract

    def initialize(abstract_table)
      @abstract = abstract_table
    end

    def column_keys
      abstract.first.map { |k,v| k } # ~> [:id, :name]
    end

    def header_row # header_row defined by hash keys of the first array:
      column_keys.map{|key,value| key.to_s} # ~> [ "id", "name"]
    end

    def body_rows
      abstract.inject([]) do |body_rows, row|
        body_rows << column_keys.map do |key|
          row[key]
        end
      end
    end

    def exec
      [ header_row ] + body_rows
    end
  end
end
