class CreateSeeds < ServiceObject
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
  UNMASKED_COLUMNS_LOGFILE = Rails.root.join("tmp", "unmasked_columns.txt").to_s

  # see if there are any string/text columns we've failed to explicitly whitelist or mask
  # without actually going through all the data
  def self.check_text_columns!
    Rails.application.eager_load!
    table_klasses = ActiveRecord::Base.
      descendants.
      map{ |c| [c.table_name, c.name] }.
      to_h

    `rm #{UNMASKED_COLUMNS_LOGFILE}`

    (ActiveRecord::Base.connection.tables - IGNORED_TABLES).each do |table|
      Table.
        new(klass: table_klasses[table].constantize).
        check_text_columns!(raise_on_miss: false)
    end
  end

  def call
    Rails.application.eager_load!
    table_klasses = ActiveRecord::Base.
      descendants.
      map{ |c| [c.table_name, c.name] }.
      to_h

    `rm #{Rails.root.join("seeds", "*").to_s}`
    `rm #{IDENTIFYING_INFO_LOGFILE}`
    `rm #{UNMASKED_COLUMNS_LOGFILE}`

    (ActiveRecord::Base.connection.tables - IGNORED_TABLES).each do |table|
      Table.call(klass: table_klasses[table].constantize)
    end
  end

  class Table < ServiceObject
    attribute :klass, Class

    def call
      check_text_columns!(raise_on_miss: true)

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
      directory_name = "seeds"
      Dir.mkdir(directory_name) unless File.directory?(directory_name)
      filename = Rails.root.join("seeds", "#{klass.table_name}.yaml").to_s
      file = File.open(filename, "w+")
      file.write(yaml)
    end

    def check_text_columns!(raise_on_miss: false)
      klass.
        columns.
        select{ |column| column.type == :text || column.type == :string}.
        map(&:name).
        each do |name|
          if !masked_key?(name) && !whitelisted?(name)
            if raise_on_miss
              raise "You forgot to mask or whitelist #{klass} #{name}"
            else
              log = File.open(UNMASKED_COLUMNS_LOGFILE, "a+")
              log.write("\nklass: #{klass}, column: #{name}")
              log.close
            end
          end
        end
    end

    def whitelisted?(column_name)
      WHITELISTED_TEXT_COLUMNS.find do |column|
        column[:klass] == klass && column[:column] == column_name
      end
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
        elsif value.is_a?(String) || value.is_a?(Integer)
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

    PHONE_NUMBER = /(?:\+?|\b)[0-9]{10}\b/

    def surnames
      return @surnames if defined?(@surnames)

      joined_surnames = VANCOUVER_COMMON_SURNAMES.
        map{ |name| Regexp.quote(name) }.
        join('|')

      @surnames = /(?<![[:alnum:]])(#{joined_surnames})(?![[:alnum:]])/i
    end

    def contains_identifying_info?(str)
      INDICATES_IDENTIFYING_INFO.any?{ |fragment| str.include?(fragment) } ||
        str[surnames] ||
        str[PHONE_NUMBER]
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
        :faker => -> (klass) { Faker::Lorem.sentence }
      },
      "description" => {
        :test => -> (klass) { klass == ReferralForm || klass == NewsletterDescriptionItem },
        :faker => -> (klass) { Faker::Lorem.sentence }
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

    WHITELISTED_TEXT_COLUMNS = [
      {klass: SubscriptionActivity, column: "trackable_type"},
      {klass: SubscriptionActivity, column: "owner_type"},
      {klass: SubscriptionActivity, column: "key"},
      {klass: SubscriptionActivity, column: "parameters"},
      {klass: SubscriptionActivity, column: "update_classification_type"},
      {klass: SubscriptionActivity, column: "type_mask_description"},
      {klass: SubscriptionActivity, column: "format_type_description"},
      {klass: SubscriptionActivity, column: "parent_type"},
      {klass: City, column: "name"},
      {klass: ClinicLocation, column: "location_opened"},
      {klass: Division, column: "name"},
      {klass: Evidence, column: "level"},
      {klass: Evidence, column: "summary"},
      {klass: FaqCategory, column: "name"},
      {klass: FaqCategory, column: "description"},
      {klass: Faq, column: "question"},
      {klass: Favorite, column: "favoritable_type"},
      {klass: FeedbackItem, column: "item_type"},
      {klass: HealthcareProvider, column: "name"},
      {klass: Hospital, column: "name"},
      {klass: Language, column: "name"},
      {klass: LatestUpdatesMask, column: "item_type"},
      {klass: Location, column: "locatable_type"},
      {klass: ProcedureSpecialization, column: "ancestry"},
      {klass: Procedure, column: "name"},
      {klass: Province, column: "name"},
      {klass: Province, column: "abbreviation"},
      {klass: Province, column: "symbol"},
      {klass: ReferralForm, column: "referrable_type"},
      {klass: Report, column: "name"},
      {klass: ScCategory, column: "name"},
      {klass: ScCategory, column: "ancestry"},
      {klass: Schedule, column: "schedulable_type"},
      {klass: SecretToken, column: "accessible_type"},
      {klass: SpecialistOffice, column: "location_opened"},
      {klass: Specialization, column: "name"},
      {klass: Specialization, column: "member_name"},
      {klass: Specialization, column: "label_name"},
      {klass: Specialization, column: "suffix"},
      {klass: Subscription, column: "classification"},
      {klass: Subscription, column: "news_type"},
      {klass: Subscription, column: "sc_item_format_type"},
      {klass: User, column: "role"},
      {klass: UserMask, column: "role"}
    ]
  end
end
