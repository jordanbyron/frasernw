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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160922143318) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "addresses", force: true do |t|
    t.string   "address1"
    t.string   "suite"
    t.string   "postalcode"
    t.string   "phone1"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hospital_id"
    t.integer  "city_id"
    t.string   "address2"
    t.integer  "clinic_id"
  end

  add_index "addresses", ["city_id"], name: "index_addresses_on_city_id", using: :btree
  add_index "addresses", ["clinic_id"], name: "index_addresses_on_clinic_id", using: :btree
  add_index "addresses", ["hospital_id"], name: "index_addresses_on_hospital_id", using: :btree

  create_table "attendances", force: true do |t|
    t.integer  "specialist_id"
    t.integer  "clinic_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_specialist",      default: true
    t.string   "freeform_firstname"
    t.string   "freeform_lastname"
    t.string   "area_of_focus"
  end

  add_index "attendances", ["clinic_location_id", "specialist_id"], name: "index_attendances_on_clinic_location_id_and_specialist_id", using: :btree
  add_index "attendances", ["clinic_location_id"], name: "index_attendances_on_clinic_id", using: :btree
  add_index "attendances", ["specialist_id"], name: "index_attendances_on_specialist_id", using: :btree

  create_table "capacities", force: true do |t|
    t.integer  "specialist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "investigation",               limit: nil
    t.integer  "procedure_specialization_id"
    t.integer  "waittime_mask",                           default: 0
    t.integer  "lagtime_mask",                            default: 0
  end

  add_index "capacities", ["procedure_specialization_id"], name: "index_capacities_on_procedure_specialization_id", using: :btree
  add_index "capacities", ["specialist_id"], name: "index_capacities_on_specialist_id", using: :btree

  create_table "cities", force: true do |t|
    t.string   "name"
    t.integer  "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",      default: false
  end

  add_index "cities", ["province_id"], name: "index_cities_on_province_id", using: :btree

  create_table "clinic_healthcare_providers", force: true do |t|
    t.integer  "clinic_id"
    t.integer  "healthcare_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clinic_healthcare_providers", ["clinic_id"], name: "index_clinic_healthcare_providers_on_clinic_id", using: :btree
  add_index "clinic_healthcare_providers", ["healthcare_provider_id"], name: "index_clinic_healthcare_providers_on_healthcare_provider_id", using: :btree

  create_table "clinic_locations", force: true do |t|
    t.integer  "clinic_id"
    t.string   "phone"
    t.string   "fax"
    t.string   "phone_extension"
    t.integer  "sector_mask",                default: 1
    t.string   "url"
    t.string   "email"
    t.text     "contact_details"
    t.integer  "wheelchair_accessible_mask", default: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "public_email"
    t.string   "location_opened"
    t.boolean  "public"
    t.boolean  "private"
    t.boolean  "volunteer"
  end

  add_index "clinic_locations", ["clinic_id"], name: "index_clinic_locations_on_clinic_id", using: :btree

  create_table "clinic_speaks", force: true do |t|
    t.integer  "clinic_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clinic_speaks", ["clinic_id"], name: "index_clinic_speaks_on_clinic_id", using: :btree
  add_index "clinic_speaks", ["language_id"], name: "index_clinic_speaks_on_language_id", using: :btree

  create_table "clinic_specializations", force: true do |t|
    t.integer  "clinic_id"
    t.integer  "specialization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clinic_specializations", ["clinic_id"], name: "index_clinic_specializations_on_clinic_id", using: :btree
  add_index "clinic_specializations", ["specialization_id"], name: "index_clinic_specializations_on_specialization_id", using: :btree

  create_table "clinics", force: true do |t|
    t.string   "name"
    t.text     "interest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "referral_criteria"
    t.text     "referral_process"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.string   "contact_notes"
    t.integer  "status_mask"
    t.text     "limitations"
    t.text     "required_investigations"
    t.text     "not_performed"
    t.boolean  "referral_fax"
    t.boolean  "referral_phone"
    t.string   "referral_other_details"
    t.boolean  "respond_by_fax"
    t.boolean  "respond_by_phone"
    t.boolean  "respond_by_mail"
    t.boolean  "respond_to_patient"
    t.text     "red_flags"
    t.boolean  "urgent_fax"
    t.boolean  "urgent_phone"
    t.string   "urgent_other_details"
    t.integer  "waittime_mask"
    t.integer  "lagtime_mask"
    t.integer  "referral_form_mask",                    default: 3
    t.integer  "patient_can_book_mask",                 default: 3
    t.text     "urgent_details"
    t.string   "deprecated_phone"
    t.string   "deprecated_fax"
    t.integer  "deprecated_sector_mask",                default: 1
    t.integer  "deprecated_wheelchair_accessible_mask", default: 3
    t.text     "referral_details"
    t.text     "admin_notes"
    t.integer  "deprecated_schedule_id"
    t.integer  "categorization_mask",                   default: 1
    t.text     "patient_instructions"
    t.text     "cancellation_policy"
    t.string   "deprecated_phone_extension"
    t.string   "saved_token"
    t.boolean  "interpreter_available",                 default: false
    t.text     "deprecated_contact_details"
    t.text     "practice_details"
    t.string   "deprecated_url"
    t.string   "deprecated_email"
    t.date     "closure_date"
    t.boolean  "hidden",                                default: false
    t.boolean  "completed_survey",                      default: true
    t.boolean  "accepting_new_referrals"
    t.boolean  "referrals_limited"
    t.boolean  "closure_scheduled",                     default: false
  end

  create_table "contacts", force: true do |t|
    t.integer  "specialist_id"
    t.integer  "user_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["specialist_id"], name: "index_contacts_on_specialist_id", using: :btree
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "demoable_news_items", force: true do |t|
    t.integer  "news_item_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "division_cities", force: true do |t|
    t.integer  "division_id"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "division_cities", ["city_id", "division_id"], name: "index_division_cities_on_city_id_and_division_id", using: :btree
  add_index "division_cities", ["city_id"], name: "index_division_cities_on_city_id", using: :btree
  add_index "division_cities", ["division_id"], name: "index_division_cities_on_division_id", using: :btree

  create_table "division_display_news_items", force: true do |t|
    t.integer  "division_id",  null: false
    t.integer  "news_item_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "division_display_sc_items", force: true do |t|
    t.integer  "division_id"
    t.integer  "sc_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "division_display_sc_items", ["division_id", "sc_item_id"], name: "index_division_display_sc_items_on_division_id_and_sc_item_id", using: :btree
  add_index "division_display_sc_items", ["division_id"], name: "index_division_display_sc_items_on_division_id", using: :btree
  add_index "division_display_sc_items", ["sc_item_id"], name: "index_division_display_sc_items_on_sc_item_id", using: :btree

  create_table "division_primary_contacts", force: true do |t|
    t.integer  "division_id"
    t.integer  "primary_contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "division_primary_contacts", ["division_id"], name: "index_division_primary_contacts_on_division_id", using: :btree
  add_index "division_primary_contacts", ["primary_contact_id"], name: "index_division_primary_contacts_on_primary_contact_id", using: :btree

  create_table "division_referral_cities", force: true do |t|
    t.integer  "division_id"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority",    default: 3
  end

  add_index "division_referral_cities", ["city_id", "division_id"], name: "index_division_referral_cities_on_city_id_and_division_id", using: :btree
  add_index "division_referral_cities", ["city_id"], name: "index_division_referral_cities_on_city_id", using: :btree
  add_index "division_referral_cities", ["division_id"], name: "index_division_referral_cities_on_division_id", using: :btree

  create_table "division_referral_city_specializations", force: true do |t|
    t.integer  "division_referral_city_id"
    t.integer  "specialization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "division_referral_city_specializations", ["division_referral_city_id"], name: "index_drcs_on_div_ref_city_id", using: :btree
  add_index "division_referral_city_specializations", ["specialization_id"], name: "index_drcs_on_specialization_id", using: :btree

  create_table "division_users", force: true do |t|
    t.integer  "division_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "division_users", ["division_id"], name: "index_division_users_on_division_id", using: :btree
  add_index "division_users", ["user_id"], name: "index_division_users_on_user_id", using: :btree

  create_table "divisions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_customized_city_priorities", default: false
  end

  create_table "edits", force: true do |t|
    t.integer  "specialist_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edits", ["specialist_id"], name: "index_edits_on_specialist_id", using: :btree

  create_table "evidences", force: true do |t|
    t.string   "level",               null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "quality_of_evidence"
    t.text     "definition"
  end

  create_table "faq_categories", force: true do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "faqs", force: true do |t|
    t.text     "question",        null: false
    t.text     "answer_markdown", null: false
    t.integer  "index",           null: false
    t.integer  "faq_category_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "faqs", ["faq_category_id"], name: "faqs_category_id", using: :btree

  create_table "favorites", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "favoritable_id"
    t.string   "favoritable_type"
  end

  add_index "favorites", ["favoritable_id", "favoritable_type"], name: "index_favorites_on_favoritable_id_and_favoritable_type", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "featured_contents", force: true do |t|
    t.integer  "sc_category_id"
    t.integer  "sc_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "division_id"
  end

  add_index "featured_contents", ["division_id"], name: "index_featured_contents_on_division_id", using: :btree
  add_index "featured_contents", ["sc_category_id"], name: "index_featured_contents_on_sc_category_id", using: :btree
  add_index "featured_contents", ["sc_item_id"], name: "index_featured_contents_on_sc_item_id", using: :btree

  create_table "feedback_items", force: true do |t|
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "user_id"
    t.text     "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",               default: false
    t.string   "freeform_email"
    t.string   "freeform_name"
    t.text     "archiving_division_ids", default: [],    array: true
  end

  add_index "feedback_items", ["target_id", "target_type"], name: "index_feedback_items_on_target_id_and_target_type", using: :btree
  add_index "feedback_items", ["user_id"], name: "index_feedback_items_on_user_id", using: :btree

  create_table "focuses", force: true do |t|
    t.integer  "clinic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "investigation"
    t.integer  "procedure_specialization_id"
    t.integer  "waittime_mask",               default: 0
    t.integer  "lagtime_mask",                default: 0
  end

  add_index "focuses", ["clinic_id"], name: "index_focuses_on_clinic_id", using: :btree
  add_index "focuses", ["procedure_specialization_id"], name: "index_focuses_on_procedure_specialization_id", using: :btree

  create_table "healthcare_providers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hospitals", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.string   "fax"
    t.string   "phone_extension"
    t.string   "saved_token"
  end

  create_table "issue_assignments", force: true do |t|
    t.integer  "issue_id"
    t.integer  "assignee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issue_subscriptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "issue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "progress_key",          default: 1
    t.integer  "source_key",            default: 4
    t.string   "priority",              default: ""
    t.string   "effort_estimate",       default: "-"
    t.date     "manual_date_entered"
    t.date     "manual_date_completed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_id"
    t.boolean  "complete_this_weekend", default: false
    t.boolean  "complete_next_meeting", default: false
  end

  create_table "languages", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "saved_token"
  end

  create_table "latest_updates_masks", force: true do |t|
    t.integer  "event_code"
    t.integer  "division_id"
    t.date     "date"
    t.string   "item_type"
    t.integer  "item_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "locations", force: true do |t|
    t.string   "locatable_type"
    t.integer  "locatable_id"
    t.integer  "address_id"
    t.integer  "hospital_in_id"
    t.integer  "clinic_in_id"
    t.string   "suite_in"
    t.string   "details_in"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_in_id"
  end

  add_index "locations", ["address_id", "location_in_id"], name: "index_locations_on_address_id_and_location_in_id", using: :btree
  add_index "locations", ["address_id"], name: "index_locations_on_address_id", using: :btree
  add_index "locations", ["clinic_in_id"], name: "index_locations_on_clinic_in_id", using: :btree
  add_index "locations", ["hospital_in_id", "location_in_id"], name: "index_locations_on_hospital_in_id_and_location_in_id", using: :btree
  add_index "locations", ["hospital_in_id"], name: "index_locations_on_hospital_in_id", using: :btree
  add_index "locations", ["locatable_id", "locatable_type"], name: "index_locations_on_locatable_id_and_locatable_type", using: :btree
  add_index "locations", ["locatable_id", "location_in_id"], name: "index_locations_on_locatable_id_and_location_in_id", using: :btree
  add_index "locations", ["location_in_id"], name: "index_locations_on_location_in_id", using: :btree

  create_table "news_items", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_start_date",   default: false
    t.boolean  "show_end_date",     default: false
    t.integer  "type_mask"
    t.integer  "owner_division_id"
    t.integer  "parent_id"
  end

  add_index "news_items", ["owner_division_id"], name: "index_news_items_on_division_id", using: :btree

  create_table "newsletter_description_items", force: true do |t|
    t.text     "description_item"
    t.integer  "newsletter_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "newsletter_description_items", ["newsletter_id"], name: "newsletter_description_items_newsletter_id", using: :btree

  create_table "newsletters", force: true do |t|
    t.integer  "month_key",             null: false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "newsletters", ["month_key"], name: "newsletters_month_key", using: :btree

  create_table "notes", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "noteable_id"
    t.string   "noteable_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "offices", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "privileges", force: true do |t|
    t.integer  "specialist_id"
    t.integer  "hospital_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "privileges", ["hospital_id"], name: "index_privileges_on_hospital_id", using: :btree
  add_index "privileges", ["specialist_id"], name: "index_privileges_on_specialist_id", using: :btree

  create_table "procedure_specializations", force: true do |t|
    t.integer  "procedure_id"
    t.integer  "specialization_id"
    t.string   "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "classification"
    t.boolean  "specialist_wait_time", default: false
    t.boolean  "clinic_wait_time",     default: false
  end

  add_index "procedure_specializations", ["ancestry"], name: "index_procedure_specializations_on_ancestry", using: :btree
  add_index "procedure_specializations", ["procedure_id"], name: "index_procedure_specializations_on_procedure_id", using: :btree
  add_index "procedure_specializations", ["specialization_id"], name: "index_procedure_specializations_on_specialization_id", using: :btree

  create_table "procedures", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "specialization_level", default: true
    t.string   "saved_token"
  end

  create_table "provinces", force: true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.string   "symbol"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referral_forms", force: true do |t|
    t.string   "referrable_type"
    t.integer  "referrable_id"
    t.string   "description"
    t.string   "form_file_name"
    t.string   "form_content_type"
    t.integer  "form_file_size"
    t.datetime "form_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referral_forms", ["referrable_id", "referrable_type"], name: "index_referral_forms_on_referrable_id_and_referrable_type", using: :btree

  create_table "review_items", force: true do |t|
    t.string   "item_type"
    t.integer  "item_id"
    t.string   "edit_source_id"
    t.text     "object"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",         default: false
    t.integer  "status",           default: 0
    t.text     "base_object"
    t.string   "edit_source_type"
  end

  add_index "review_items", ["item_id", "item_type"], name: "index_review_items_on_item_id_and_item_type", using: :btree

  create_table "sc_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_on_front_page",   default: true
    t.integer  "sort_order",           default: 10
    t.string   "ancestry"
    t.boolean  "searchable",           default: true
    t.boolean  "evidential",           default: false
    t.integer  "index_display_format", default: 0
    t.boolean  "in_global_navigation", default: false
    t.boolean  "filterable",           default: false
  end

  add_index "sc_categories", ["ancestry"], name: "index_sc_categories_on_ancestry", using: :btree

  create_table "sc_item_mailings", force: true do |t|
    t.integer  "sc_item_id"
    t.text     "user_division_ids", default: [], array: true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_role"
  end

  create_table "sc_item_specialization_procedure_specializations", force: true do |t|
    t.integer  "sc_item_specialization_id"
    t.integer  "procedure_specialization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sc_item_specialization_procedure_specializations", ["procedure_specialization_id", "sc_item_specialization_id"], name: "index_sc_item_s_p_s_on_psid_sc_item_s_id", using: :btree
  add_index "sc_item_specialization_procedure_specializations", ["procedure_specialization_id"], name: "index_sc_item_sps_on_procedure_specialization_id", using: :btree
  add_index "sc_item_specialization_procedure_specializations", ["sc_item_specialization_id"], name: "index_sc_item_sps_on_sc_item_specialization_id", using: :btree

  create_table "sc_item_specializations", force: true do |t|
    t.integer  "sc_item_id"
    t.integer  "specialization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sc_item_specializations", ["sc_item_id"], name: "index_sc_item_specializations_on_sc_item_id", using: :btree
  add_index "sc_item_specializations", ["specialization_id"], name: "index_sc_item_specializations_on_specialization_id", using: :btree

  create_table "sc_items", force: true do |t|
    t.integer  "sc_category_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_mask"
    t.string   "url"
    t.text     "markdown_content"
    t.boolean  "searchable",            default: true
    t.boolean  "shared_care",           default: false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "division_id"
    t.boolean  "shareable",             default: true
    t.integer  "evidence_id"
    t.boolean  "demoable",              default: false
    t.boolean  "can_email"
  end

  add_index "sc_items", ["division_id"], name: "index_sc_items_on_division_id", using: :btree
  add_index "sc_items", ["evidence_id"], name: "index_sc_items_on_evidence_id", using: :btree
  add_index "sc_items", ["sc_category_id"], name: "index_sc_items_on_sc_category_id", using: :btree

  create_table "schedule_days", force: true do |t|
    t.boolean  "scheduled"
    t.time     "from"
    t.time     "to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "break_from"
    t.time     "break_to"
  end

  create_table "schedules", force: true do |t|
    t.string   "schedulable_type"
    t.integer  "schedulable_id"
    t.integer  "monday_id"
    t.integer  "tuesday_id"
    t.integer  "wednesday_id"
    t.integer  "thursday_id"
    t.integer  "friday_id"
    t.integer  "saturday_id"
    t.integer  "sunday_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["friday_id"], name: "index_schedules_on_friday_id", using: :btree
  add_index "schedules", ["monday_id"], name: "index_schedules_on_monday_id", using: :btree
  add_index "schedules", ["saturday_id"], name: "index_schedules_on_saturday_id", using: :btree
  add_index "schedules", ["schedulable_id", "schedulable_type"], name: "index_schedules_on_schedulable_id_and_schedulable_type", using: :btree
  add_index "schedules", ["sunday_id"], name: "index_schedules_on_sunday_id", using: :btree
  add_index "schedules", ["thursday_id"], name: "index_schedules_on_thursday_id", using: :btree
  add_index "schedules", ["tuesday_id"], name: "index_schedules_on_tuesday_id", using: :btree
  add_index "schedules", ["wednesday_id"], name: "index_schedules_on_wednesday_id", using: :btree

  create_table "secret_tokens", force: true do |t|
    t.integer  "creator_id",                      null: false
    t.string   "recipient",                       null: false
    t.integer  "accessible_id",                   null: false
    t.string   "accessible_type",                 null: false
    t.string   "token",                           null: false
    t.boolean  "expired",         default: false, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "secret_tokens", ["accessible_id", "accessible_type"], name: "secret_token_item", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: true do |t|
    t.integer  "value",      null: false
    t.integer  "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "settings", ["identifier"], name: "settings_identifier", using: :btree

  create_table "specialist_offices", force: true do |t|
    t.integer  "specialist_id"
    t.integer  "office_id"
    t.string   "phone"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_extension"
    t.integer  "sector_mask",            default: 1
    t.string   "direct_phone"
    t.string   "direct_phone_extension"
    t.string   "url"
    t.string   "email"
    t.boolean  "open_saturday",          default: false
    t.boolean  "open_sunday",            default: false
    t.integer  "schedule_id"
    t.string   "public_email"
    t.string   "location_opened"
    t.boolean  "public"
    t.boolean  "private"
    t.boolean  "volunteer"
  end

  add_index "specialist_offices", ["office_id"], name: "index_specialist_offices_on_office_id", using: :btree
  add_index "specialist_offices", ["specialist_id", "office_id"], name: "index_specialist_offices_on_specialist_id_and_office_id", using: :btree
  add_index "specialist_offices", ["specialist_id"], name: "index_specialist_offices_on_specialist_id", using: :btree

  create_table "specialist_speaks", force: true do |t|
    t.integer  "specialist_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "specialist_speaks", ["language_id"], name: "index_specialist_speaks_on_language_id", using: :btree
  add_index "specialist_speaks", ["specialist_id"], name: "index_specialist_speaks_on_specialist_id", using: :btree

  create_table "specialist_specializations", force: true do |t|
    t.integer  "specialist_id"
    t.integer  "specialization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "specialist_specializations", ["specialist_id"], name: "index_specialist_specializations_on_specialist_id", using: :btree
  add_index "specialist_specializations", ["specialization_id"], name: "index_specialist_specializations_on_specialization_id", using: :btree

  create_table "specialists", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.text     "practice_limitations"
    t.text     "interest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.text     "red_flags"
    t.string   "referral_criteria"
    t.string   "saved_token"
    t.string   "contact_notes"
    t.text     "not_interested"
    t.text     "all_procedure_info"
    t.string   "referral_other_details"
    t.string   "urgent_other_details"
    t.text     "required_investigations"
    t.text     "not_performed"
    t.text     "status_details"
    t.integer  "status_mask"
    t.boolean  "referral_fax"
    t.boolean  "referral_phone"
    t.boolean  "respond_by_fax"
    t.boolean  "respond_by_phone"
    t.boolean  "respond_by_mail"
    t.boolean  "respond_to_patient"
    t.boolean  "urgent_fax"
    t.boolean  "urgent_phone"
    t.integer  "waittime_mask"
    t.integer  "lagtime_mask"
    t.integer  "billing_number"
    t.integer  "referral_form_mask",               default: 3
    t.integer  "patient_can_book_mask",            default: 3
    t.date     "practice_end_date"
    t.date     "practice_restart_date"
    t.text     "urgent_details"
    t.string   "goes_by_name"
    t.integer  "sex_mask",                         default: 3
    t.text     "referral_details"
    t.text     "admin_notes"
    t.integer  "categorization_mask",              default: 1
    t.text     "patient_instructions"
    t.text     "cancellation_policy"
    t.integer  "referral_clinic_id"
    t.text     "hospital_clinic_details"
    t.boolean  "interpreter_available",            default: false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "is_gp",                            default: false
    t.boolean  "is_internal_medicine",             default: false
    t.boolean  "sees_only_children",               default: false
    t.boolean  "hidden",                           default: false
    t.boolean  "completed_survey",                 default: true
    t.boolean  "works_from_offices",               default: false
    t.boolean  "accepting_new_direct_referrals",   default: false
    t.boolean  "accepting_new_indirect_referrals", default: false
    t.boolean  "direct_referrals_limited",         default: false
    t.boolean  "practice_end_scheduled",           default: false
    t.boolean  "practice_restart_scheduled",       default: false
    t.integer  "practice_end_reason_key",          default: 2
    t.text     "practice_details"
  end

  add_index "specialists", ["referral_clinic_id"], name: "index_specialists_on_referral_clinic_id", using: :btree

  create_table "specialization_options", force: true do |t|
    t.integer  "specialization_id"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "division_id"
    t.boolean  "hide_from_division_users",         default: false
    t.boolean  "is_new",                           default: false
    t.integer  "content_owner_id"
    t.integer  "open_to_type",                     default: 1
    t.integer  "open_to_sc_category_id"
    t.boolean  "show_specialist_categorization_1", default: true
    t.boolean  "show_specialist_categorization_2", default: true
    t.boolean  "show_specialist_categorization_3", default: true
    t.boolean  "show_specialist_categorization_4", default: true
    t.boolean  "show_specialist_categorization_5", default: false
  end

  add_index "specialization_options", ["content_owner_id"], name: "index_specialization_options_on_content_owner_id", using: :btree
  add_index "specialization_options", ["division_id"], name: "index_specialization_options_on_division_id", using: :btree
  add_index "specialization_options", ["open_to_sc_category_id"], name: "index_specialization_options_on_open_to_sc_category_id", using: :btree
  add_index "specialization_options", ["owner_id", "specialization_id"], name: "index_specialization_options_on_owner_id_and_specialization_id", using: :btree
  add_index "specialization_options", ["owner_id"], name: "index_specialization_options_on_owner_id", using: :btree
  add_index "specialization_options", ["specialization_id"], name: "index_specialization_options_on_specialization_id", using: :btree

  create_table "specializations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "saved_token"
    t.string   "member_name"
    t.boolean  "deprecated_open_to_clinic_tab", default: false
    t.string   "label_name",                    default: "Specialist"
    t.string   "suffix"
    t.boolean  "mask_filters_by_referral_area", default: false
    t.boolean  "members_are_physicians",        default: true
  end

  create_table "subscription_divisions", force: true do |t|
    t.integer  "division_id"
    t.integer  "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscription_divisions", ["division_id"], name: "index_subscription_divisions_on_division_id", using: :btree
  add_index "subscription_divisions", ["subscription_id"], name: "index_subscription_divisions_on_subscription_id", using: :btree

  create_table "subscription_sc_categories", force: true do |t|
    t.integer  "subscription_id"
    t.integer  "sc_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscription_sc_categories", ["sc_category_id"], name: "index_subscription_sc_categories_on_sc_category_id", using: :btree
  add_index "subscription_sc_categories", ["subscription_id"], name: "index_subscription_sc_categories_on_subscription_id", using: :btree

  create_table "subscription_specializations", force: true do |t|
    t.integer  "specialization_id"
    t.integer  "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscription_specializations", ["specialization_id"], name: "index_subscription_specializations_on_specialization_id", using: :btree
  add_index "subscription_specializations", ["subscription_id"], name: "index_subscription_specializations_on_subscription_id", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.string   "target_class"
    t.string   "news_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "interval"
    t.string   "sc_item_format_type"
  end

  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "teleservices", force: true do |t|
    t.integer  "teleservice_provider_id"
    t.integer  "teleservice_provider_type"
    t.integer  "service_type"
    t.boolean  "telephone",                 default: false
    t.boolean  "video",                     default: false
    t.boolean  "email",                     default: false
    t.boolean  "store",                     default: false
    t.string   "contact_note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teleservices", ["teleservice_provider_id", "teleservice_provider_type"], name: "index_teleservices_on_provider", using: :btree

  create_table "user_controls_clinics", force: true do |t|
    t.integer  "user_id"
    t.integer  "clinic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_visited"
  end

  add_index "user_controls_clinics", ["clinic_id"], name: "index_user_controls_clinics_on_clinic_id", using: :btree
  add_index "user_controls_clinics", ["user_id"], name: "index_user_controls_clinics_on_user_id", using: :btree

  create_table "user_controls_specialists", force: true do |t|
    t.integer  "user_id"
    t.integer  "specialist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_visited"
  end

  add_index "user_controls_specialists", ["specialist_id"], name: "index_user_controls_specialists_on_specialist_id", using: :btree
  add_index "user_controls_specialists", ["user_id"], name: "index_user_controls_specialists_on_user_id", using: :btree

  create_table "user_mask_divisions", force: true do |t|
    t.integer  "division_id"
    t.integer  "user_mask_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "user_masks", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "persistence_token"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "role"
    t.string   "perishable_token",        default: "",    null: false
    t.string   "saved_token"
    t.integer  "type_mask",               default: 1
    t.datetime "last_request_at"
    t.boolean  "agree_to_toc",            default: false
    t.boolean  "active",                  default: true
    t.integer  "failed_login_count",      default: 0
    t.date     "activated_at"
    t.boolean  "persist_in_demo",         default: false
    t.integer  "last_request_format_key", default: 1
    t.boolean  "is_developer",            default: false
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.integer  "review_item_id"
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at", using: :btree
  add_index "versions", ["item_id"], name: "index_versions_on_item_id", using: :btree
  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "videos", force: true do |t|
    t.string   "title"
    t.string   "video_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "views", force: true do |t|
    t.integer  "specialist_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "views", ["specialist_id"], name: "index_views_on_specialist_id", using: :btree

end
