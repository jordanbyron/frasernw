# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120730235201) do

  create_table "addresses", :force => true do |t|
    t.string    "address1"
    t.string    "suite"
    t.string    "postalcode"
    t.string    "phone1"
    t.string    "fax"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "hospital_id"
    t.integer   "city_id"
    t.string    "address2"
    t.integer   "clinic_id"
  end

  add_index "addresses", ["city_id"], :name => "index_addresses_on_city_id"
  add_index "addresses", ["clinic_id"], :name => "index_addresses_on_clinic_id"
  add_index "addresses", ["hospital_id"], :name => "index_addresses_on_hospital_id"

  create_table "attendances", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "clinic_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "is_specialist",      :default => true
    t.string    "freeform_firstname"
    t.string    "freeform_lastname"
    t.string    "area_of_focus"
  end

  add_index "attendances", ["clinic_id"], :name => "index_attendances_on_clinic_id"
  add_index "attendances", ["specialist_id"], :name => "index_attendances_on_specialist_id"

  create_table "capacities", :force => true do |t|
    t.integer   "specialist_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "investigation"
    t.integer   "procedure_specialization_id"
  end

  add_index "capacities", ["procedure_specialization_id"], :name => "index_capacities_on_procedure_specialization_id"
  add_index "capacities", ["specialist_id"], :name => "index_capacities_on_specialist_id"

  create_table "cities", :force => true do |t|
    t.string    "name"
    t.integer   "province_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "cities", ["province_id"], :name => "index_cities_on_province_id"

  create_table "clinic_addresses", :force => true do |t|
    t.integer   "clinic_id"
    t.integer   "address_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "clinic_healthcare_providers", :force => true do |t|
    t.integer   "clinic_id"
    t.integer   "healthcare_provider_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "clinic_healthcare_providers", ["clinic_id"], :name => "index_clinic_healthcare_providers_on_clinic_id"
  add_index "clinic_healthcare_providers", ["healthcare_provider_id"], :name => "index_clinic_healthcare_providers_on_healthcare_provider_id"

  create_table "clinic_speaks", :force => true do |t|
    t.integer   "clinic_id"
    t.integer   "language_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "clinic_speaks", ["clinic_id"], :name => "index_clinic_speaks_on_clinic_id"
  add_index "clinic_speaks", ["language_id"], :name => "index_clinic_speaks_on_language_id"

  create_table "clinic_specializations", :force => true do |t|
    t.integer   "clinic_id"
    t.integer   "specialization_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "clinic_specializations", ["clinic_id"], :name => "index_clinic_specializations_on_clinic_id"
  add_index "clinic_specializations", ["specialization_id"], :name => "index_clinic_specializations_on_specialization_id"

  create_table "clinics", :force => true do |t|
    t.string    "name"
    t.text      "status"
    t.text      "interest"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.text      "referral_criteria"
    t.text      "referral_process"
    t.string    "responds_via"
    t.string    "contact_name"
    t.string    "contact_phone"
    t.string    "contact_email"
    t.string    "contact_notes"
    t.integer   "status_mask"
    t.text      "limitations"
    t.text      "location_opened"
    t.text      "required_investigations"
    t.text      "not_performed"
    t.boolean   "referral_fax"
    t.boolean   "referral_phone"
    t.string    "referral_other_details"
    t.boolean   "referral_form_old"
    t.boolean   "respond_by_fax"
    t.boolean   "respond_by_phone"
    t.boolean   "respond_by_mail"
    t.boolean   "respond_to_patient"
    t.boolean   "patient_can_book_old"
    t.text      "red_flags"
    t.boolean   "urgent_fax"
    t.boolean   "urgent_phone"
    t.string    "urgent_other_details"
    t.integer   "waittime_mask"
    t.integer   "lagtime_mask"
    t.integer   "referral_form_mask",         :default => 3
    t.integer   "patient_can_book_mask",      :default => 3
    t.text      "urgent_details"
    t.string    "phone"
    t.string    "fax"
    t.integer   "sector_mask",                :default => 1
    t.integer   "wheelchair_accessible_mask", :default => 3
    t.text      "referral_details"
    t.text      "admin_notes"
    t.integer   "schedule_id"
    t.integer   "categorization_mask",        :default => 1
    t.text      "patient_instructions"
    t.text      "cancellation_policy"
    t.string    "phone_extension"
    t.string    "saved_token"
    t.boolean   "interpreter_available",      :default => false
    t.text      "contact_details"
    t.text      "status_details"
    t.string    "url"
  end

  create_table "contacts", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "user_id"
    t.text      "notes"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "contacts", ["specialist_id"], :name => "index_contacts_on_specialist_id"
  add_index "contacts", ["user_id"], :name => "index_contacts_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer   "priority",   :default => 0
    t.integer   "attempts",   :default => 0
    t.text      "handler"
    t.text      "last_error"
    t.timestamp "run_at"
    t.timestamp "locked_at"
    t.timestamp "failed_at"
    t.string    "locked_by"
    t.string    "queue"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "edits", :force => true do |t|
    t.integer   "specialist_id"
    t.text      "notes"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "edits", ["specialist_id"], :name => "index_edits_on_specialist_id"

  create_table "favorites", :force => true do |t|
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "favoritable_id"
    t.string    "favoritable_type"
  end

  add_index "favorites", ["favoritable_id", "favoritable_type"], :name => "index_favorites_on_favoritable_id_and_favoritable_type"
  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"

  create_table "featured_contents", :force => true do |t|
    t.integer  "sc_category_id"
    t.integer  "sc_item_id"
    t.integer  "front_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedback_items", :force => true do |t|
    t.string    "item_type"
    t.integer   "item_id"
    t.integer   "user_id"
    t.text      "feedback"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "focuses", :force => true do |t|
    t.integer   "clinic_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "investigation"
    t.integer   "procedure_specialization_id"
  end

  add_index "focuses", ["clinic_id"], :name => "index_focuses_on_clinic_id"
  add_index "focuses", ["procedure_specialization_id"], :name => "index_focuses_on_procedure_specialization_id"

  create_table "fronts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "healthcare_providers", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "hospital_addresses", :force => true do |t|
    t.integer   "hospital_id"
    t.integer   "address_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "hospitals", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "phone"
    t.string    "fax"
    t.string    "phone_extension"
    t.string    "saved_token"
  end

  create_table "languages", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "saved_token"
  end

  create_table "locations", :force => true do |t|
    t.string    "locatable_type"
    t.integer   "locatable_id"
    t.integer   "address_id"
    t.integer   "hospital_in_id"
    t.integer   "clinic_in_id"
    t.string    "suite_in"
    t.string    "details_in"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "locations", ["clinic_in_id"], :name => "index_locations_on_clinic_in_id"
  add_index "locations", ["hospital_in_id"], :name => "index_locations_on_hospital_in_id"
  add_index "locations", ["locatable_id", "locatable_type"], :name => "index_locations_on_locatable_id_and_locatable_type"

  create_table "moderations", :force => true do |t|
    t.integer   "moderatable_id"
    t.string    "moderatable_type",               :null => false
    t.string    "attr_name",        :limit => 60, :null => false
    t.text      "attr_value",                     :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "offices", :force => true do |t|
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "privileges", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "hospital_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "privileges", ["hospital_id"], :name => "index_privileges_on_hospital_id"
  add_index "privileges", ["specialist_id"], :name => "index_privileges_on_specialist_id"

  create_table "procedure_specializations", :force => true do |t|
    t.integer   "procedure_id"
    t.integer   "specialization_id"
    t.string    "ancestry"
    t.boolean   "mapped",            :default => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "classification"
  end

  add_index "procedure_specializations", ["ancestry"], :name => "index_procedure_specializations_on_ancestry"
  add_index "procedure_specializations", ["procedure_id"], :name => "index_procedure_specializations_on_procedure_id"
  add_index "procedure_specializations", ["specialization_id"], :name => "index_procedure_specializations_on_specialization_id"

  create_table "procedures", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "specialization_level", :default => true
    t.string    "saved_token"
  end

  create_table "provinces", :force => true do |t|
    t.string    "name"
    t.string    "abbreviation"
    t.string    "symbol"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "referral_forms", :force => true do |t|
    t.string    "referrable_type"
    t.integer   "referrable_id"
    t.string    "description"
    t.string    "form_file_name"
    t.string    "form_content_type"
    t.integer   "form_file_size"
    t.timestamp "form_updated_at"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "referral_forms", ["referrable_id", "referrable_type"], :name => "index_referral_forms_on_referrable_id_and_referrable_type"

  create_table "review_items", :force => true do |t|
    t.string    "item_type"
    t.integer   "item_id"
    t.string    "whodunnit"
    t.text      "object"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "review_items", ["item_id", "item_type"], :name => "index_review_items_on_item_id_and_item_type"

  create_table "reviews", :force => true do |t|
    t.string    "item_type",      :null => false
    t.integer   "item_id",        :null => false
    t.string    "whodunnit"
    t.text      "object"
    t.text      "object_changes"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "reviews", ["item_id", "item_type"], :name => "index_reviews_on_item_id_and_item_type"

  create_table "sc_categories", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "sc_item_specialization_procedure_specializations", :force => true do |t|
    t.integer   "sc_item_specialization_id"
    t.integer   "procedure_specialization_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sc_item_specialization_procedure_specializations", ["procedure_specialization_id"], :name => "index_sc_item_sps_on_procedure_specialization_id"
  add_index "sc_item_specialization_procedure_specializations", ["sc_item_specialization_id"], :name => "index_sc_item_sps_on_sc_item_specialization_id"

  create_table "sc_item_specializations", :force => true do |t|
    t.integer   "sc_item_id"
    t.integer   "specialization_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sc_item_specializations", ["sc_item_id"], :name => "index_sc_item_specializations_on_sc_item_id"
  add_index "sc_item_specializations", ["specialization_id"], :name => "index_sc_item_specializations_on_specialization_id"

  create_table "sc_items", :force => true do |t|
    t.integer   "sc_category_id"
    t.string    "title"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "type_mask"
    t.string    "url"
    t.text      "markdown_content"
    t.boolean   "inline"
    t.boolean   "searchable",       :default => true
    t.boolean   "tool",             :default => false
    t.boolean   "shared_care",      :default => false
  end

  add_index "sc_items", ["sc_category_id"], :name => "index_sc_items_on_sc_category_id"

  create_table "schedule_days", :force => true do |t|
    t.boolean   "scheduled"
    t.time      "from"
    t.time      "to"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.string    "schedulable_type"
    t.integer   "schedulable_id"
    t.integer   "monday_id"
    t.integer   "tuesday_id"
    t.integer   "wednesday_id"
    t.integer   "thursday_id"
    t.integer   "friday_id"
    t.integer   "saturday_id"
    t.integer   "sunday_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "schedules", ["friday_id"], :name => "index_schedules_on_friday_id"
  add_index "schedules", ["monday_id"], :name => "index_schedules_on_monday_id"
  add_index "schedules", ["saturday_id"], :name => "index_schedules_on_saturday_id"
  add_index "schedules", ["schedulable_id", "schedulable_type"], :name => "index_schedules_on_schedulable_id_and_schedulable_type"
  add_index "schedules", ["sunday_id"], :name => "index_schedules_on_sunday_id"
  add_index "schedules", ["thursday_id"], :name => "index_schedules_on_thursday_id"
  add_index "schedules", ["tuesday_id"], :name => "index_schedules_on_tuesday_id"
  add_index "schedules", ["wednesday_id"], :name => "index_schedules_on_wednesday_id"

  create_table "sessions", :force => true do |t|
    t.string    "session_id", :null => false
    t.text      "data"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "specialist_addresses", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "address_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "specialist_offices", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "office_id"
    t.string    "phone"
    t.string    "fax"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "phone_extension"
    t.integer   "sector_mask",            :default => 1
    t.string    "direct_phone"
    t.string    "direct_phone_extension"
    t.string    "url"
  end

  add_index "specialist_offices", ["office_id"], :name => "index_specialist_offices_on_office_id"
  add_index "specialist_offices", ["specialist_id"], :name => "index_specialist_offices_on_specialist_id"

  create_table "specialist_speaks", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "language_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "specialist_speaks", ["language_id"], :name => "index_specialist_speaks_on_language_id"
  add_index "specialist_speaks", ["specialist_id"], :name => "index_specialist_speaks_on_specialist_id"

  create_table "specialist_specializations", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "specialization_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "specialist_specializations", ["specialist_id"], :name => "index_specialist_specializations_on_specialist_id"
  add_index "specialist_specializations", ["specialization_id"], :name => "index_specialist_specializations_on_specialization_id"

  create_table "specialists", :force => true do |t|
    t.string    "firstname"
    t.string    "lastname"
    t.text      "practise_limitations"
    t.text      "interest"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "direct_phone_old"
    t.string    "contact_name"
    t.string    "contact_phone"
    t.string    "contact_email"
    t.text      "red_flags"
    t.string    "responds_via"
    t.string    "referral_criteria"
    t.string    "saved_token"
    t.string    "contact_notes"
    t.text      "not_interested"
    t.text      "all_procedure_info"
    t.string    "referral_other_details"
    t.string    "referral_request"
    t.boolean   "patient_can_book_old",       :default => false
    t.string    "urgent_other_details"
    t.text      "required_investigations"
    t.text      "not_performed"
    t.text      "status_details"
    t.string    "location_opened"
    t.integer   "status_mask"
    t.boolean   "referral_fax"
    t.boolean   "referral_phone"
    t.boolean   "respond_by_fax"
    t.boolean   "respond_by_phone"
    t.boolean   "respond_by_mail"
    t.boolean   "respond_to_patient"
    t.boolean   "urgent_fax"
    t.boolean   "urgent_phone"
    t.boolean   "referral_form_old"
    t.integer   "waittime_mask"
    t.integer   "lagtime_mask"
    t.integer   "billing_number"
    t.integer   "referral_form_mask",         :default => 3
    t.integer   "patient_can_book_mask",      :default => 3
    t.date      "unavailable_from"
    t.date      "unavailable_to"
    t.text      "urgent_details"
    t.string    "goes_by_name"
    t.string    "direct_phone_extension_old"
    t.integer   "sex_mask",                   :default => 3
    t.text      "referral_details"
    t.text      "admin_notes"
    t.integer   "categorization_mask",        :default => 1
    t.text      "patient_instructions"
    t.text      "cancellation_policy"
    t.integer   "referral_clinic_id"
    t.text      "hospital_clinic_details"
    t.boolean   "interpreter_available",      :default => false
    t.text      "address_update"
  end

  add_index "specialists", ["referral_clinic_id"], :name => "index_specialists_on_referral_clinic_id"

  create_table "specializations", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "in_progress", :default => false
    t.string    "saved_token"
    t.string    "member_name"
  end

  create_table "user_controls_clinics", :force => true do |t|
    t.integer   "user_id"
    t.integer   "clinic_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "user_controls_clinics", ["clinic_id"], :name => "index_user_controls_clinics_on_clinic_id"
  add_index "user_controls_clinics", ["user_id"], :name => "index_user_controls_clinics_on_user_id"

  create_table "user_controls_specialists", :force => true do |t|
    t.integer   "user_id"
    t.integer   "specialist_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "user_controls_specialists", ["specialist_id"], :name => "index_user_controls_specialists_on_specialist_id"
  add_index "user_controls_specialists", ["user_id"], :name => "index_user_controls_specialists_on_user_id"

  create_table "users", :force => true do |t|
    t.string    "email"
    t.string    "persistence_token"
    t.string    "crypted_password"
    t.string    "password_salt"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "name"
    t.string    "role"
    t.string    "perishable_token",  :default => "", :null => false
    t.string    "saved_token"
  end

  create_table "versions", :force => true do |t|
    t.string    "item_type",      :null => false
    t.integer   "item_id",        :null => false
    t.string    "event",          :null => false
    t.string    "whodunnit"
    t.text      "object"
    t.timestamp "created_at"
    t.text      "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "views", :force => true do |t|
    t.integer   "specialist_id"
    t.text      "notes"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "views", ["specialist_id"], :name => "index_views_on_specialist_id"

end
