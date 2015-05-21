module CSVReport
  # writes a set of tables to the file path provided
  class Service
    attr_reader :file_path, :tables

    def initialize(file_path, *tables)
      @file_path, @tables = file_path, tables
    end

    def exec
      CSV.write_from_array(
        file_path,
        concatenated_tables
      )
    end

    def concatenated_tables
      tables.inject([]) do |memo, table|
        memo + (table << [""])
      end
    end
  end
end
