class CreateSeeds < ServiceObject
  # TODO: skip test accounts
  # TODO: at the current rate, masking versions would take ~470 hours

  IGNORED_TABLES = [
    "metrics",
    "delayed_jobs",
    "sessions",
    "versions",
    "schema_migrations",
    "review_items"
  ]

  IDENTIFYING_INFO_LOGFILE = Rails.root.join("tmp", "identifying_info.txt").to_s

  def call
    Rails.application.eager_load!
    table_klasses = Hash[ActiveRecord::Base.send(:descendants).collect{|c| [c.table_name, c.name]}]

    `rm #{Rails.root.join("seeds", "*").to_s}`
    `rm #{IDENTIFYING_INFO_LOGFILE}`

    (ActiveRecord::Base.connection.tables - IGNORED_TABLES).each do |table|
      Table.call(klass: table_klasses[table].constantize)
    end
  end

  class Table < ServiceObject
    attribute :klass, Class

    def call
      count = klass.count

      yaml = klass.
        all.
        to_a.
        each_with_index.
        map do |record, index|
          puts "Masking #{klass} #{(index + 1)}/#{count}, id: #{record.id}"

          @id = record.id

          mask_hash(record.attributes)
        end.
        to_yaml

      filename = Rails.root.join("seeds", "#{klass.table_name}.yaml").to_s
      file = File.open(filename, "w+")
      file.write(yaml)
    end

    def mask_hash(hash)
      hash.map do |key, value|
        mask_hash_pair(key, value)
      end.to_h
    end

    def mask_hash_pair(key, value)
      if value == "" || value == nil
        return [ key, value ]
      elsif value.is_a?(Hash)
        return [ key, mask_hash(value) ]
      elsif value.is_a?(String)
        if is_json?(value)
          hashed_value = JSON.parse(value)

          return [ key, mask_hash(hashed_value).to_json ]
        elsif is_yaml?(value)
          deserialized_value = YAML.load(value)

          if deserialized_value.is_a?(Hash)
            return [ key, mask_hash(deserialized_value).to_yaml ]
          else
            masked = mask_hash_pair(key, deserialized_value)

            return [ key, masked[1].to_yaml ]
          end
        end
      end

      if masked_key?(key)
        if value.is_a?(Array)
          return [ key, mask_array(value, key) ]
        elsif value.is_a?(String)
          return [ key, mask_value(key) ]
        end
      end

      # double check values we pass through unmasked
      if value.is_a?(String) && contains_identifying_info?(value)
        log = File.open(IDENTIFYING_INFO_LOGFILE, "a+")
        log.write("\nklass: #{klass}, id: #{@id}, key: #{key}, val: #{value}")
        log.close
      end

      return [ key, value ]
    end

    def contains_identifying_info?(str)
      INDICATES_IDENTIFYING_INFO.any?{ |fragment| str.include?(fragment) } ||
        VANCOUVER_COMMON_SURNAMES.any? do |surname|
          str[/(?<![[:alnum:]])#{Regexp.quote(surname)}(?![[:alnum:]])/i]
        end
    end

    def mask_array(array, key)
      array.map do |value|
        if value == "" || value == nil
          value
        else
          mask_value(key)
        end
      end
    end

    ## educated guesses
    def is_json?(val)
      val.starts_with?("{")
    end

    def is_yaml?(val)
      val.starts_with?("---")
    end
    ###

    def masked_key?(key)
      config = masked_fragment_config(key)

      !(config.nil?) && (!(config.has_key?(:test)) || config[:test].call(klass))
    end

    def masked_fragment_config(key)
      MASKED_FRAGMENTS.find{ |fragment, config| key.include?(fragment) }.try(:[], 1)
    end

    def mask_value(key)
      config = masked_fragment_config(key)

      if config[:faker].present?
        config[:faker].call(klass)
      else
        "seeded_#{key}"
      end
    end

    KLASSES_ALLOWING_NAME = [
      ScCategory,
      City,
      Division,
      FaqCategory,
      Specialization,
      HealthcareProvider,
      Language,
      Hospital,
      Procedure,
      Province,
      Report
    ]

    MASKED_FRAGMENTS = {
      "form_file_name" => {
        :faker => -> (klass) { "seed_form" }
      },
      "photo_file_name" => {
        :faker => -> (klass) { "seed_photo" }
      },
      "document_file_name" => {
        :faker => -> (klass) { "seed_document" }
      },
      "firstname" => {
        :faker => -> (klass) { Faker::Name.first_name }
      },
      "lastname" => {
        :faker => -> (klass) { Faker::Name.last_name}
      },
      "name" => {
        :test => -> (klass) { !(KLASSES_ALLOWING_NAME.include?(klass)) },
        :faker => -> (klass) { klass == Clinic ? Faker::Company.name : Faker::Name.name }
      },
      "phone" => {
        :faker => -> (klass) { Faker::PhoneNumber.phone_number }
      },
      "fax" => {
        :faker => -> (klass) { Faker::PhoneNumber.phone_number }
      },
      "email" => {
        :faker => -> (klass) { Faker::Internet.email }
      },
      "address1" => {
        :faker => -> (klass) { Faker::Address.street_address }
      },
      "address2" => {
        :faker => -> (klass) { Faker::Address.street_address }
      },
      "postalcode" => {
        :faker => -> (klass) { Faker::Address.postcode }
      },
      "url" => {
        :faker => -> (klass) { "http://www.google.ca" }
      },
      "answer_markdown" => {
        :faker => -> (klass) { "This is an answer to an FAQ question" }
      },
      "title" => {
        :faker => -> (klass) { "#{klass.to_s.tableize.gsub("_", " ")} title" }
      },
      "description" => {
        :test => -> (klass) { klass == ReferralForm },
        :faker => -> (klass) { "Referral form description" }
      },
      "recipient" => {
        :faker => -> (klass) { Faker::Internet.email }
      },
      "city_id" => {
        :test => -> (klass) { klass == Address },
        :faker => -> (klass) { City.unscoped.select("id").first(order: "RANDOM()")[:id] }
      },
      "investigation" => {},
      "suite" => {},
      "body" => {},
      "area_of_focus" => {},
      "referral_criteria" => {},
      "referral_process" => {},
      "content" => {},
      "data" => {},
      "session_id" => {},
      "feedback" => {},
      "password" => {},
      "token" => {},
      "comment" => {},
      "note" => {},
      "status" => {},
      "patient_instructions" => {},
      "details" => {},
      "red_flags" => {},
      "not_performed" => {},
      "limitations" => {},
      "location_opened_old" => {},
      "policy" => {},
      "required_investigations" => {},
      "interest" => {},
      "all_procedure_info" => {},
      "urgent_details" => {},
      "cancellation_policy" => {}
    }

    VANCOUVER_COMMON_SURNAMES = [
      "Lee",
      "Wong",
      "Chan",
      "Smith",
      "Kim",
      "Chen",
      "Gill",
      "Li",
      "Brown",
      "Johnson",
      "Wang",
      "Wilson",
      "Leung",
      "Anderson",
      "Lam",
      "Jones",
      "Taylor",
      "Singh",
      "Liu",
      "Ng",
      "Wu",
      "Ho",
      "Chow",
      "Macdonald",
      "Miller",
      "Chang",
      "Huang",
      "Lin",
      "Cheung",
      "Martin",
      "Lau",
      "Young",
      "Thompson",
      "Scott",
      "Nguyen",
      "Cheng",
      "Zhang",
      "Yu",
      "Stewart",
      "Yang",
      "Sidhu",
      "Sandhu",
      "Robinson",
      "Moore",
      "Dhaliwal",
      "Mitchell",
      "Tang",
      "Walker",
      "McDonald",
      "Ross",
      "Johnston",
      "Reid",
      "Grewal",
      "Chu",
      "Ma",
      "Thomas",
      "Hall",
      "Lai",
      "Chung",
      "Wright",
      "Choi",
      "Dhillon",
      "Jackson",
      "Baker",
      "Evans",
      "Robertson",
      "King",
      "Bell",
      "Davis",
      "Lo",
      "Graham",
      "Roberts",
      "Harris",
      "Watson",
      "Peters",
      "Friesen",
      "Tam",
      "Mann",
      "Lewis",
      "Lim",
      "Clarke",
      "Phillips",
      "Yeung",
      "Hill",
      "Davies",
      "Murray",
      "Grant",
      "Brar",
      "Morrison",
      "Tran",
      "Fung",
      "Hamilton"
    ]

    INDICATES_IDENTIFYING_INFO = [
      "Dr.",
      "Doctor",
      "@"
    ]
  end
end
