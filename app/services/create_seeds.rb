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
    "subscription_sc_categories",
    "subscription_divisions",
    "subscription_news_item_types",
    "subscription_specializations",
    "review_items",
    "secret_tokens",
    "demoable_news_items",
    "division_display_news_items",
    "user_controls_specialists",
    "user_controls_clinics"
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

    TABLES_HANDLED_INDIVIDUALLY.values.each do |value|
      value.call
    end

    tables_handled_automatically.each do |table|
      Table.call(klass: table_klasses[table].constantize)
    end

    PostProcess.call
  end

  def tables_handled_automatically
    ActiveRecord::Base.connection.tables - IGNORED_TABLES - TABLES_HANDLED_INDIVIDUALLY.keys
  end

  TABLES_HANDLED_INDIVIDUALLY = {
    "sc_items" => Proc.new{
      File.write(
        Rails.root.join("seeds", "sc_items.yaml"),
        ScItem.demoable.provincial.map(&:attributes).to_yaml
      )
    },
    "news_items" => Proc.new{
      news_items = NewsItem.
        demoable.
        map(&:attributes).
        map do |attrs|
          attrs.merge({
            "owner_division_id" => 1,
            "start_date" => Date.yesterday,
            "end_date" => 10.years.from_now
          })
        end

      File.write(
        Rails.root.join("seeds", "news_items.yaml"),
        news_items.to_yaml
      )
    },
    "users" => Proc.new{
      prod_users = User.admin.map(&:attributes)

      demo_users_cmd = "\"puts('START_DUMP' + User.where(persist_in_demo: true).map(&:attributes).to_yaml)\""
      demo_users_cmd_result = `heroku run rails runner #{demo_users_cmd} --app pathwaysbcdev`
      demo_users = YAML.load(demo_users_cmd_result[/(?<=START_DUMP)[^\e]+/m])

      users = demo_users + prod_users

      File.write(
        Rails.root.join("seeds", "users.yaml"),
        users.to_yaml
      )
    }
  }

  class PostProcess < ServiceObject
    def call
      new_specialist_specializations = new_specialization_links("specialist")
      new_capacities = new_procedure_links("capacities", "specialist", new_specialist_specializations)

      new_clinic_specializations = new_specialization_links("clinic")
      new_focuses = new_procedure_links("focuses", "clinic", new_clinic_specializations)

      File.open(
        Rails.root.join("seeds", "specialist_specializations.yaml").to_s,
        "w+"
      ).write(new_specialist_specializations.to_yaml)

      File.open(
        Rails.root.join("seeds", "capacities.yaml").to_s,
        "w+"
      ).write(new_capacities.to_yaml)

      File.open(
        Rails.root.join("seeds", "clinic_specializations.yaml").to_s,
        "w+"
      ).write(new_clinic_specializations.to_yaml)

      File.open(
        Rails.root.join("seeds", "focuses.yaml").to_s,
        "w+"
      ).write(new_focuses.to_yaml)
    end


    # mix up the assignment of specialists/clinics to specializations
    # keeping constant the distribution
    # (number of specialists/clinics per specific specialization,
    # number of specializations per specialist/clinic)

    def new_specialization_links(referrable_type)
      original = YAML.load_file(
        Rails.root.join("seeds", "#{referrable_type}_specializations.yaml").to_s
      )

      referrables = original.count_by do |specialization_link|
        specialization_link["#{referrable_type}_id"]
      end

      specializations = original.count_by do |specialization_link|
        specialization_link["specialization_id"]
      end

      id = 0

      specializations.inject([]) do |memo, (specialization_id, count)|
        memo + count.times.inject([]) do |inner_memo|
          referrable_id = referrables.keys.sample
          referrables[referrable_id] = referrables[referrable_id] - 1
          referrables.delete(referrable_id) if referrables[referrable_id] == 0
          created_at = rand(Date.civil(2012, 1, 26)..Date.current)
          updated_at = rand(created_at..Date.current)
          id += 1

          inner_memo << {
            "#{referrable_type}_id" => referrable_id,
            "specialization_id" => specialization_id,
            "created_at" => created_at,
            "updated_at" => updated_at,
            "id" => id
          }
        end
      end
    end

    # mix up the assignment of specialists/clinics to procedure specializations
    # keeping constant the distribution
    # (number of specialists/clinics per specific procedure specialization,
    # number of procedure specializations per specialist/clinic)
    #
    # make sure that the new assignments match up with the new specialization
    # assignments

    def new_procedure_links(procedure_link_name, referrable_type, specialization_links)
      original = YAML.load_file(
        Rails.root.join("seeds", "#{procedure_link_name}.yaml").to_s
      )

      specializations = original.select do |procedure_link|
        procedure_link["procedure_specialization_id"].present?
      end.map do |procedure_link|
        ps = ProcedureSpecialization.
          includes(:specialization).
          where(id: procedure_link["procedure_specialization_id"]).
          first
        sp = ps.specialization

        procedure_link.merge(
          "specialization_id" => sp.try(:id)
        )
      end.select do |procedure_link|
        procedure_link["specialization_id"].present?
      end.group_by do |procedure_link|
        procedure_link["specialization_id"]
      end.map do |specialization_id, procedure_links|
        # take our new specialist assignments and map them to the existing
        # distribution across procedure specializations
        new_referrable_ids = specialization_links.select do |referrable_specialization|
          referrable_specialization["specialization_id"] == specialization_id
        end.map do |referrable_specialization|
          referrable_specialization["#{referrable_type}_id"]
        end.uniq

        referrables = procedure_links.count_by do |procedure_link|
          procedure_link["#{referrable_type}_id"]
        end.map do |referrable_id, procedure_link_count|
          next unless new_referrable_ids.any?

          new_referrable_id = new_referrable_ids.sample
          new_referrable_ids.delete(new_referrable_id)

          [ new_referrable_id, procedure_link_count ]
        end.select(&:present?).to_h

        procedure_specializations = procedure_links.count_by do |procedure_link|
          procedure_link["procedure_specialization_id"]
        end

        [
          specialization_id,
          {
            referrables: referrables,
            procedure_specializations: procedure_specializations
          }
        ]
      end.to_h

      id = 0

      specializations.inject([]) do |memo, (specialization_id, associated)|
        memo + associated[:procedure_specializations].inject([]) do |inner_memo, (procedure_specialization_id, count)|
          referrables = associated[:referrables]
          inner_memo + count.times.inject([]) do |ps_procedure_links|
            if referrables.keys.any?
              referrable_id = referrables.keys.sample
              referrables[referrable_id] = referrables[referrable_id] - 1
              referrables.delete(referrable_id) if referrables[referrable_id] == 0
              created_at = rand(Date.civil(2012, 1, 26)..Date.current)
              updated_at = rand(created_at..Date.current)
              id += 1

              ps_procedure_links << {
                "id" => id,
                "procedure_specialization_id" => procedure_specialization_id,
                "#{referrable_type}_id" => referrable_id,
                "created_at" => created_at,
                "updated_at" => updated_at
              }
            else
              ps_procedure_links
            end
          end
        end
      end
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
      if masked_key?(key)
        if value.is_a?(Array)
          [ key, mask_array(value, key) ]
        else
          [ key, mask_value(key, hash) ]
        end
      elsif value == "" || value == nil
        [ key, value ]
      elsif value.is_a?(Hash)
        [ key, mask_hash(value) ]
      elsif value.is_a?(String) && is_json?(value)
          hashed_value = JSON.parse(value)

          [ key, mask_hash(hashed_value).to_json ]
      elsif value.is_a?(String) && is_yaml?(value)
        deserialized_value = YAML.load(value)

        if deserialized_value.is_a?(Hash)
          [ key, mask_hash(deserialized_value).to_yaml ]
        else
          masked = mask_hash_pair(key, deserialized_value, hash)

          [ key, masked[1].to_yaml ]
        end
      else
        # double check string values we pass through unmasked
        if value.is_a?(String) && contains_identifying_info?(value)
          raise "#{klass}, #{key}, #{value} Contains identifying info!"

          # log = File.open(IDENTIFYING_INFO_LOGFILE, "a+")
          # log.write("\nklass: #{klass}, id: #{@id}, key: #{key}, val: #{value}")
          # log.close
        else
          [ key, value ]
        end
      end
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

    RAND_BOOLEAN = Proc.new{ [true, false].sample }
    RAND_MSP = [50000...60000]
    MASKED_FRAGMENTS = {
      "goes_by_name" => {
        :faker => Proc.new{ |klass| "" }
      },
      "form_file_name" => {
        :faker => Proc.new{ |klass| "seed_form" }
      },
      "photo_file_name" => {
        :faker => Proc.new{ |klass| "seed_photo" }
      },
      "document_file_name" => {
        :test => Proc.new{ |klass| klass != NewsItem },
        :faker => Proc.new{ |klass| "seed_document" }
      },
      "firstname" => {
        :faker => Proc.new{ |klass| Faker::Name.first_name }
      },
      "lastname" => {
        :faker => Proc.new{ |klass| Faker::Name.last_name}
      },
      "name" => {
        :test => Proc.new{ |klass| !(KLASSES_ALLOWING_NAME.include?(klass)) },
        :faker => Proc.new do |klass|
          if klass == Clinic
            Faker::Company.name
          else
            "#{Faker::Name.first_name} #{Faker::Name.last_name}"
          end
        end
      },
      "phone_extension" => {
        :faker => Proc.new{ |klass| Faker::PhoneNumber.extension }
      },
      "phone" => {
        :faker => Proc.new{ |klass| Faker::PhoneNumber.phone_number }
      },
      "fax" => {
        :faker => Proc.new{ |klass| Faker::PhoneNumber.phone_number }
      },
      "hospital_id" => {
        :test => Proc.new{ |klass| klass == Privilege },
        :faker => Proc.new{ |klass| Hospital.random_id }
      },
      "clinic_id" => {
        :test => Proc.new{ |klass| klass == Attendance },
        :faker => Proc.new{ |klass| Clinic.random_id }
      },
      "unavailable_to" => {
        :faker => Proc.new{ |klass| rand(Date.civil(2012, 1, 26)..Date.civil(2017, 4, 1)) }
      },
      "unavailable_from" => {
        :faker => Proc.new{ |klass| rand(Date.civil(2012, 1, 26)..Date.civil(2017, 4, 1)) }
      },
      "created_at" => {
        :faker => Proc.new{ |klass, record| rand(Date.civil(2012, 1, 26)..record["created_at"].to_date) }
      },
      "referral_fax" => { :faker => RAND_BOOLEAN },
      "referral_phone" => { :faker => RAND_BOOLEAN },
      "respond_by_fax" => { :faker => RAND_BOOLEAN },
      "respond_by_phone" => { :faker => RAND_BOOLEAN },
      "respond_by_mail" => { :faker => RAND_BOOLEAN },
      "respond_to_patient" => { :faker => RAND_BOOLEAN },
      "urgent_fax" => { :faker => RAND_BOOLEAN },
      "urgent_phone" => { :faker => RAND_BOOLEAN },
      "sex_mask" => { :faker => Proc.new{ [1, 2, 3].sample } },
      "waittime_mask" => { :faker => Proc.new{|klass| klass::WAITTIME_LABELS.keys.sample } },
      "lagtime_mask" => {
        :faker => Proc.new{ |klass| klass::LAGTIME_LABELS.keys.sample }
      },
      "categorization_mask" => {
        :faker => Proc.new do |klass|
          if klass == Specialist
            rand() < 0.9 ? 1 : [3, 5].sample
          else
            1
          end
        end
      },
      "status_mask" => {
        :faker => Proc.new do |klass|
          if klass == Specialist
            if rand() < 0.9
              1
            else
              (1..11).to_a.except(3).except(7).sample
            end
          else
            if rand() < 0.9
              1
            else
              (1..7).to_a.except(3).sample
            end
          end
        end
      },
      "updated_at" => {
        :faker => Proc.new{ |klass, record| rand(record["updated_at"].to_date..Date.current) }
      },
      "email" => {
        :faker => Proc.new{ |klass| Faker::Internet.email }
      },
      "billing_number" => {
        :faker => Proc.new{ |klass| RAND_MSP.sample }
      },
      "address1" => {
        :faker => Proc.new{ |klass| Faker::Address.street_address }
      },
      "address2" => {
        :faker => Proc.new{ |klass| Faker::Address.street_address }
      },
      "postalcode" => {
        :faker => Proc.new{ |klass| Faker::Address.postcode }
      },
      "url" => {
        :faker => Proc.new{ |klass| "http://www.google.ca" }
      },
      "answer_markdown" => {
        :faker => Proc.new{ |klass| "This is an answer to an FAQ question" }
      },
      "title" => {
        :faker => Proc.new{ |klass| "This is a title" }
      },
      "description" => {
        :test => Proc.new{ |klass| klass == ReferralForm },
        :faker => Proc.new{ |klass| "Referral Form Title" }
      },
      "recipient" => {
        :faker => Proc.new{ |klass| Faker::Internet.email }
      },
      "city_id" => {
        :test => Proc.new{ |klass| klass == Address },
        :faker => Proc.new{ |klass, hash| hash["city_id"].nil? ? nil : City.random_id }
      },
      "investigation" => {
        :faker => Proc.new{ |klass| "Complete medical history." }
        },
      "suite" => {
        :faker => Proc.new{ |klass| Faker::Address.secondary_address }
        },
      "body" => {
        :faker => Proc.new{ |klass| "This is a news item." }
      },
      "area_of_focus" => {
        :faker => Proc.new{ |klass| "Post-surgical recuperation" }
        },
      "referral_criteria" => {
        :faker => Proc.new{ |klass| "Laparascopic analysis" }
        },
      "referral_process" => {
        :faker => Proc.new{ |klass| "Email preferred." }
        },
      "content" => {
        :faker => Proc.new{ |klass| "We seek to provide the best possible medical care to our patients." }
      },
      "data" => {},
      "session_id" => {},
      "feedback" => {},
      "password" => {},
      "token" => {},
      "note" => {
        :faker => Proc.new{ |klass| "We seek to provide the best possible medical care to our patients." }
        },
      "patient_instructions" => {
        :faker => Proc.new{ |klass| "Take no food 12 hours prior to appiontment" }
        },
      "details" => {
        :faker => Proc.new{ |klass| "Some details." }
        },
      "red_flags" => {
        :faker => Proc.new{ |klass| "Oncology" }
        },
      "not_performed" => {
        :faker => Proc.new{ |klass| "Vaccinations" }
        },
      "limitations" => {
        :faker => Proc.new{ |klass| "Not wheelchair accessible" }
        },
      "location_opened_old" => {},
      "required_investigations" => {
        :faker => Proc.new{ |klass| "Complete vaccination records" }
        },
      "interest" => {
        :faker => Proc.new{ |klass| "Post-surgical Counselling" }
        },
      "all_procedure_info" => {
        :faker => Proc.new{ |klass| "Ensure records are provided at least 2 days prior to appiontment" }
        },
      "urgent_details" => {
        :faker => Proc.new{ |klass| "Telephone or Email." }
        },
      "cancellation_policy" => {
        :faker => Proc.new{ |klass| "24 hour notice required." }
      }
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
      {klass: NewsletterDescriptionItem, column: "description_item"},
      {klass: City, column: "name"},
      {klass: ClinicLocation, column: "location_opened"},
      {klass: Division, column: "name"},
      {klass: Evidence, column: "level"},
      {klass: Evidence, column: "quality_of_evidence"},
      {klass: Evidence, column: "definition"},
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
