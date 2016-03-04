class ImportSeeds < ServiceObject
  def call
    seeds_directory = Rails.root.join("seeds", "*")

    # get all our model classes
    Rails.application.eager_load!
    table_klasses = Hash[ActiveRecord::Base.send(:descendants).collect{|c| [c.table_name, c.name]}]

    Dir[seeds_directory].each do |file_path|
      records = YAML.load_file(file_path)

      next unless records.any?

      table_name = File.basename(file_path, ".yaml")
      klass = table_klasses[table_name].constantize

      puts "importing #{klass}"

      columns = records.first.keys
      values = records.map(&:values)

      klass.import(columns, values, validate: false)
    end

    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end

    fixup_clinic_names!

    CreateSeedUsers.call
  end

  def fixup_clinic_names!
    Clinic.all.each do |clinic|
      clinic.update_attribute(
        :name,
        "#{clinic.cities.sample} #{clinic.specialization.sample} Clinic"
      )
    end
  end
end
