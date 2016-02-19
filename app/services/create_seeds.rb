class CreateSeeds < ServiceObject
  # TODO: at the current rate, masking versions would take ~470 hours


  IGNORED_TABLES = [
    "activities",
    "metrics",
    "delayed_jobs",
    "sessions",
    "versions",
    "schema_migrations",
    "subscriptions",
    "subscriptions_sc_categories",
    "subscription_divisions",
    "subscription_news_item_types",
    "subscription_specialization",
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

    FileUtils.ensure_folder_exists(
      Rails.root.join("seeds").to_s
    )

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
        mask_hash_pair(key, value, hash)
      end.to_h
    end

    def mask_hash_pair(key, value, hash)
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
            masked = mask_hash_pair(key, deserialized_value, hash)

            return [ key, masked[1].to_yaml ]
          end
        end
      end

      if masked_key?(key)
        if value.is_a?(Array)
          return [ key, mask_array(value, key) ]
        else
          return [ key, mask_value(key, hash) ]
        end
      end

      # double check string values we pass through unmasked
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

    def mask_array(array, key, hash)
      array.map do |value|
        if value == "" || value == nil
          value
        else
          mask_value(key, hash)
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

    def mask_value(key, hash)
      config = masked_fragment_config(key)

      if config[:faker].present?
        config[:faker].call(klass, hash)
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

    RAND_BOOLEAN = Proc.new { [true, false].sample }
    MASKED_FRAGMENTS = {
      "form_file_name" => {
        :faker => Proc.new { |klass| "seed_form" }
      },
      "photo_file_name" => {
        :faker => Proc.new { |klass| "seed_photo" }
      },
      "document_file_name" => {
        :faker => Proc.new { |klass| "seed_document" }
      },
      "firstname" => {
        :faker => Proc.new { |klass| Faker::Name.first_name }
      },
      "lastname" => {
        :faker => Proc.new { |klass| Faker::Name.last_name}
      },
      "name" => {
        :test => Proc.new { |klass| !(KLASSES_ALLOWING_NAME.include?(klass)) },
        :faker => Proc.new { |klass| klass == Clinic ? Faker::Company.name : Faker::Name.name }
      },
      "phone" => {
        :faker => Proc.new { |klass| Faker::PhoneNumber.phone_number }
      },
      "fax" => {
        :faker => Proc.new { |klass| Faker::PhoneNumber.phone_number }
      },
      "hospital_id" => {
        :test => Proc.new { |klass| klass == Privilege },
        :faker => Proc.new { |klass| Hospital.random_id }
      },
      "clinic_id" => {
        :test => Proc.new { |klass| klass == Attendance },
        :faker => Proc.new { |klass| Clinic.random_id }
      },
      "unavailable_to" => {
        :faker => Proc.new { |klass| rand(Date.civil(2012, 1, 26)..Date.civil(2017, 4, 1)) }
      },
      "unavailable_from" => {
        :faker => Proc.new { |klass| rand(Date.civil(2012, 1, 26)..Date.civil(2017, 4, 1)) }
      },
      "created_at" => {
        :faker => Proc.new { |klass, record| rand(Date.civil(2012, 1, 26)..record["created_at"]) }
      },
      "referral_fax" => { :faker => RAND_BOOLEAN },
      "referral_phone" => { :faker => RAND_BOOLEAN },
      "respond_by_fax" => { :faker => RAND_BOOLEAN },
      "respond_by_phone" => { :faker => RAND_BOOLEAN },
      "respond_by_mail" => { :faker => RAND_BOOLEAN },
      "respond_to_patient" => { :faker => RAND_BOOLEAN },
      "urgent_fax" => { :faker => RAND_BOOLEAN },
      "urgent_phone" => { :faker => RAND_BOOLEAN },
      "sex_mask" => { :faker => Proc.new { [1, 2, 3].sample } },
      "waittime_mask" => { :faker => Proc.new {|klass| klass::WAITTIME_LABELS.keys.sample } },
      "lagtime_mask" => { :faker => Proc.new {|klass| klass::LAGTIME_LABELS.keys.sample } },
      "categorization_mask" => { :faker => Proc.new {|klass| klass::CATEGORIZATION_LABELS.keys.sample } },
      "updated_at" => {
        :faker => Proc.new { |klass, record| rand(record["updated_at"]..Date.current) }
      },
      "email" => {
        :faker => Proc.new { |klass| Faker::Internet.email }
      },
      "billing_number" => {
        :faker => Proc.new { |klass| 55555 }
      },
      "address1" => {
        :faker => Proc.new { |klass| Faker::Address.street_address }
      },
      "address2" => {
        :faker => Proc.new { |klass| Faker::Address.street_address }
      },
      "postalcode" => {
        :faker => Proc.new { |klass| Faker::Address.postcode }
      },
      "url" => {
        :faker => Proc.new { |klass| "http://www.google.ca" }
      },
      "answer_markdown" => {
        :faker => Proc.new { |klass| "This is an answer to an FAQ question" }
      },
      "title" => {
        :faker => Proc.new { |klass| Faker::Lorem.sentence }
      },
      "description" => {
        :test => Proc.new { |klass| klass == ReferralForm || klass == NewsletterDescriptionItem },
        :faker => Proc.new { |klass| Faker::Lorem.sentence }
      },
      "recipient" => {
        :faker => Proc.new { |klass| Faker::Internet.email }
      },
      "city_id" => {
        :test => Proc.new { |klass| klass == Address },
        :faker => Proc.new { |klass| City.random_id }
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
