class ImportSeeds < ServiceObject
  def call
    seeds_directory = Rails.root.join("seeds", "*")

    # get all our model classes
    Rails.application.eager_load!
    table_klasses = Hash[ActiveRecord::Base.send(:descendants).collect{|c| [c.table_name, c.name]}]

    Dir[seeds_directory].each do |file_path|
      records = YAML.load_file(file_path)
      table_name = File.basename(file_path, ".yaml")
      klass = table_klasses[table_name].constantize

      records.each_with_index do |record, index|
        puts "Importing #{table_name} #{index}"

        klass.new(record, without_protection: true).save(validate: false)
      end
    end

    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
end
