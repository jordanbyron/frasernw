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

    PublicActivity.enabled = false

    create_latest_updates!
    clone_news_items!
    display_news_items!

    PublicActivity.enabled = true
  end

  def fixup_clinic_names!
    PaperTrail.enabled = false

    Clinic.all.each do |clinic|
      city_name = clinic.cities.map(&:name).sample
      place_name = ["Square ", "Centre ", "Plaza ", ""].sample
      specialty_name = clinic.specializations.map(&:name).sample

      clinic.update_attribute(
        :name,
        "#{city_name} #{place_name}#{specialty_name} Clinic"
      )
    end

    PaperTrail.enabled = true
  end

  def create_latest_updates!
    latest_updates = []

    specialists = Specialist.
      all.
      select{|specialist| specialist.accepting_new_patients? }.
      select{|specialist| specialist.cities.any? }.
      shuffle.
      first(1)

    specialists.each do |specialist|
      office = "<a href='/specialists/#{specialist.id}'>#{specialist.name}'s office</a> (#{specialist.specializations.map(&:name).to_sentence})"
      opened = "has recently opened in #{specialist.cities.map(&:name).to_sentence} and is accepting new referrals."

      latest_updates << "#{office} #{opened}"
    end

    clinics = Clinic.
      all.
      select{|clinic| clinic.accepting_new_patients? }.
      select{|clinic| clinic.cities.any? }.
      shuffle.
      first(1)


    clinics.each do |clinic|
      clinic_location = "<a href='/clinics/#{clinic.id}'>#{clinic.name}</a> (#{clinic.specializations.map(&:name).to_sentence})"
      opened = "has recently opened in #{clinic.cities.map(&:name).to_sentence} and is accepting new referrals."

      latest_updates << "#{clinic_location} #{opened}"
    end

    latest_updates.each do |update|
      NewsItem.create(
        owner_division_id: 1,
        title: update,
        type_mask: NewsItem::TYPE_SPECIALIST_CLINIC_UPDATE,
        start_date: rand(1.year.ago..1.month.ago),
        end_date: rand(10.years.from_now..11.years.from_now)
      )
    end
  end

  def clone_news_items!
    Division.all.map(&:id).except(1).each do |division_id|
      NewsItem.where(owner_division_id: 1).each do |item|
        NewsItem.create(item.attributes.merge("owner_division_id" => division_id))
      end
    end
  end

  def display_news_items!
    NewsItem.all.each do |item|
      item.division_display_news_items.create(
        division_id: item.owner_division_id
      )
    end
  end
end
