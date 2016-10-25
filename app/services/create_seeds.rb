class CreateSeeds < ServiceObject
  def call
    raise "Can't run that here" if ENV["APP_NAME"] === "pathwaysbc"

    PaperTrail.enabled = false

    [
      :mask_tables,
      :mask_specialization_links,
      :mask_procedure_links,
      :fixup_clinic_names!,
      :import_demo_users!,
      :create_latest_updates!,
      :clone_news_items!,
      :display_news_items!
    ].each do |method|
      puts "#{method.to_s.gsub("_", " ")}:\n"

      send(method)
    end

    PaperTrail.enabled = true
  end

  def mask_tables
    Rails.application.eager_load!

    (SeedCreator.descendants - SeedCreator.subclasses).
      sort_by(&:to_s).
      each{|seed_creator| mask_table(seed_creator) }
  end

  def mask_table(seed_creator)
    puts "Masking #{seed_creator.to_s.match(/(::)(.+)/)[2]}"

    model =
      if seed_creator.const_defined?("Model")
        seed_creator.const_get("Model")
      else
        Object.const_get(seed_creator.to_s.match(/(::)(.+)/)[2])
      end

    if seed_creator < SeedCreator::SkippedTable
      model.delete_all
    else
      if seed_creator.const_defined?("Filter")
        model.
          all.
          reject(&seed_creator.const_get("Filter")).
          map(&:delete)
      end

      model.all.each do |record|
        update = seed_creator::Handlers.inject({}) do |memo, (attribute, handler)|
          if handler == :pass_through
            memo
          else
            memo.merge(attribute => handler.call(record[attribute]))
          end
        end

        record.update_columns(update) unless update.empty?
      end
    end
  end

  def mask_specialization_links
    [
      [ ClinicSpecialization, "clinic_id"],
      [ SpecialistSpecialization, "specialist_id"]
    ].each do |config|
      referrable_distribution = config[0].
        all.
        count_by{ |link| link.send(config[1]) }

      config[0].all.each do |link|
        referrable_id = referrable_distribution.keys.sample

        referrable_distribution[referrable_id] =
          referrable_distribution[referrable_id] - 1

        if referrable_distribution[referrable_id] == 0
          referrable_distribution.delete(referrable_id)
        end

        link.update_attribute(config[1], referrable_id)
      end
    end
  end

  def mask_procedure_links
    [
      [ Focus, "clinic_id", Clinic, :clinics],
      [ Capacity, "specialist_id", Specialist, :specialists]
    ].each do |config|
      referrable_distribution = config[0].
        all.
        count_by{ |link| link.send(config[1]) }

      specialization_referrables = Specialization.
        all.
        includes(config[3]).
        inject({}) do |memo, specialization|
          memo.merge(specialization.id => specialization.send(config[3]).map(&:id))
        end

      config[0].includes(procedure: :specializations).all.each do |link|
        if link.procedure.nil?
          link.destroy
          next
        end

        eligible_referrables = link.
          procedure.
          specializations.
          map(&config[4]).
          flatten.
          uniq.
          map(&:id)

        referrable_id = (referrable_distribution.keys & eligible_referrables).sample

        if referrable_id.nil?
          link.destroy
          next
        end

        referrable_distribution[referrable_id] =
          referrable_distribution[referrable_id] - 1

        if referrable_distribution[referrable_id] == 0
          referrable_distribution.delete(referrable_id)
        end

        link.update_attribute(config[1], referrable_id)
      end
    end
  end

  def import_demo_users!
    raw_dump =
      `heroku run rails runner "CreateSeeds.dump_users!" --app pathwaysbcdemo`

    parsed_dump = YAML.load(
      raw_dump[/(?<=START_DUMP)[^\e]+/m]
    )

    parsed_dump.each do |user_attributes|
      User.new(user_attributes, without_protection: true).save!(validate: false)
    end
  end

  def self.dump_users!
    demo_users = User.where(persist_in_demo: true).map do |user|
      user.
        attributes.
        except("id").
        merge("division_ids" => user.divisions.map(&:id))
    end

    puts('START_DUMP' + demo_users.to_yaml)
  end

  def self.dump_users!
    demo_users = User.where(persist_in_demo: true).map do |user|
      user.
        attributes.
        except("id").
        merge("division_ids" => user.divisions.map(&:id))
    end

    puts('START_DUMP' + demo_users.to_yaml)
  end

  def fixup_clinic_names!
    Clinic.all.each do |clinic|
      city_name = clinic.cities.map(&:name).sample
      place_name = ["Square ", "Centre ", "Plaza ", ""].sample
      specialty_name = clinic.specializations.map(&:name).sample

      clinic.update_attribute(
        :name,
        "#{city_name} #{place_name}#{specialty_name} Clinic"
      )
    end
  end

  def create_latest_updates!
    latest_updates = []

    specialists = Specialist.
      select{ |specialist| specialist.accepting_new_direct_referrals? }.
      select{ |specialist| specialist.cities.any? }.
      shuffle.
      first(1)

    specialists.each do |specialist|
      office =
        "<a href='/specialists/#{specialist.id}'>#{specialist.name}'s office</a> "\
        "(#{specialist.specializations.map(&:name).to_sentence})"
      opened =
        "has recently opened in #{specialist.cities.map(&:name).to_sentence} "\
        "and is accepting new referrals."

      latest_updates << "#{office} #{opened}"
    end

    clinics = Clinic.
      select{ |clinic| clinic.accepting_new_referrals? }.
      select{ |clinic| clinic.cities.any? }.
      shuffle.
      first(1)


    clinics.each do |clinic|
      clinic_location =
        "<a href='/clinics/#{clinic.id}'>#{clinic.name}</a> "\
        "(#{clinic.specializations.map(&:name).to_sentence})"
      opened =
        "has recently opened in #{clinic.cities.map(&:name).to_sentence} "\
        "and is accepting new referrals."

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
