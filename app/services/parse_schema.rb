class ParseSchema < ServiceObject
  def call
    schema = File.readlines(
      Rails.root.join("db", "schema.rb")
    )

    tables = {}

    current_table_name = nil

    schema.each do |line|
      if line.include?("create_table")
        current_table_name = line.scan(/[^\"]+/)[1].to_sym
        tables[current_table_name] = {}
      elsif !current_table_name.nil? && line.include?("end\n")
        current_table_name = nil
      elsif !current_table_name.nil?
        column_name = line.scan(/[^\"]+/)[1].to_sym
        column_type = line[/(?<=t\.)[^\s]+/].to_sym

        tables[current_table_name][column_name] = column_type
      end
    end

    tables
  end
end
