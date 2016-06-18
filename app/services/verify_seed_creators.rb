class VerifySeedCreators < ServiceObject
  def call
    Rails.application.eager_load!

    unhandled_tables = []
    unhandled_columns = []
    nonexistent_columns = []

    ParseSchema.call.each do |table, columns|
      if !SeedCreators.const_defined?(table.to_s.classify, false)
        unhandled_tables << table
      else
        seed_creator = SeedCreators.const_get(table.to_s.classify)

        if seed_creator < SeedCreator::HandledTable
          column_names = columns.keys

          table_unhandled_columns = (column_names - seed_creator::Handlers.keys).
            map{|column| { table: table, name: column } }
          unhandled_columns = unhandled_columns + table_unhandled_columns

          table_nonexistent_columns = (seed_creator::Handlers.keys - column_names).
            map{|column| { table: table, name: column } }
          nonexistent_columns = nonexistent_columns + table_nonexistent_columns
        end
      end
    end

    nonexistent_tables = ((SeedCreator.descendants - SeedCreator.subclasses).
      map(&:to_s).
      map{|name| name.match(/(::)(.+)/)[2] }.
      map(&:tableize) - ParseSchema.call.keys.map(&:to_s)).
      map(&:to_sym)

    {
      unhandled_tables: unhandled_tables,
      nonexistent_tables: nonexistent_tables,
      unhandled_columns: unhandled_columns,
      nonexistent_columns: nonexistent_columns
    }
  end

  class Warn < ServiceObject
    def call
      discrepancies = VerifySeedCreators.call

      if discrepancies[:unhandled_tables].any?
        puts "\n"
        puts "\n"
        puts "WARNING: No seed creators defined for the following tables: "

        discrepancies[:unhandled_tables].each do |table|
          puts "  - #{table}"
        end
      end

      if discrepancies[:nonexistent_tables].any?
        puts "\n"
        puts "\n"
        puts "WARNING: Seed creators defined for the following non-existent tables: "

        discrepancies[:nonexistent_tables].each do |table|
          puts "  - #{table}"
        end
      end

      if discrepancies[:unhandled_columns].any?
        puts "\n"
        puts "\n"
        puts "WARNING: No seed creators defined for the following columns: "

        discrepancies[:unhandled_columns].each do |column|
          puts "  - #{column[:table]}:#{column[:name]}"
        end
      end

      if discrepancies[:nonexistent_columns].any?
        puts "\n"
        puts "\n"
        puts "WARNING: Seed creators defined for the following non-existent columns: "

        discrepancies[:nonexistent_columns].each do |column|
          puts "  - #{column[:table]}:#{column[:name]}"
        end
      end

      return nil
    end
  end
end
