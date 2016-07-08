class UpdateSeedCreators < ServiceObject

  def call
    discrepancies = VerifySeedCreators.call

    handle_unhandled_tables(discrepancies[:unhandled_tables])
    handle_unhandled_columns(discrepancies[:unhandled_columns])

    remove_nonexistent_tables(discrepancies[:nonexistent_tables])
    remove_nonexistent_columns(discrepancies[:nonexistent_columns])
  end

  def schema
    @schema ||= ParseSchema.call
  end

  def handle_unhandled_tables(unhandled_tables)
    unhandled_tables.each do |table|
      File.open(
        Rails.root.join("app","services", "seed_creators", "#{table.to_s.singularize}.rb"),
        "w"
      ) do |file|
        file.write("module SeedCreators\n")
        file.write("  class #{table.to_s.classify} < SeedCreator::SkippedTable\n")
        file.write("  end\n")
        file.write("end\n")

        file.write("\n")

        file.write("module SeedCreators\n")
        file.write("  class #{table.to_s.classify} < SeedCreator::HandledTable\n")
        file.write("    Handlers = {\n")

        schema[table].each do |column, type|
          file.write("      #{column}: #{type},\n")
        end

        file.write("    }\n")
        file.write("  end\n")
        file.write("end\n")
      end
    end
  end

  def handle_unhandled_columns(unhandled_columns)
    unhandled_columns.each do |column|
      File.open(
        Rails.root.join(
          "app",
          "services",
          "seed_creators",
          "#{column[:table].to_s.singularize}.rb"
        ),
        "r+"
      ) do |file|
        contents = file.read

        column_type = schema[column[:table]][column[:name]]
        index = contents.match(/\n\s\s\s\s}/).offset(0)[0]

        contents.insert(
          index,
          "\n      #{column[:name]}: #{column_type}"
        )

        file.truncate(0)

        file.write(contents)
      end
    end
  end

  def remove_nonexistent_tables(nonexistent_tables)
    nonexistent_tables.each do |table|
      File.delete(
        Rails.root.join("app","services", "seed_creators", "#{table.to_s.singularize}.rb")
      )
    end
  end

  def remove_nonexistent_columns(nonexistent_columns)
    nonexistent_columns.each do |column|
      File.open(
        Rails.root.join(
          "app",
          "services",
          "seed_creators",
          "#{column[:table].to_s.singularize}.rb"
        ),
        "r+"
      ) do |file|
        contents = file.read

        contents.gsub!(/\n.+#{Regexp.quote(column[:name])}.+/, "")

        file.truncate(0)

        file.write(contents)
      end
    end
  end
end
