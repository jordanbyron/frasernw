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

ActiveRecord::Schema.define(:version => 20111216175034) do

  create_table "addresses", :force => true do |t|
    t.string   "address1"
    t.string   "address2"
    t.string   "postalcode"
    t.string   "city"
    t.string   "province"
    t.string   "phone1"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hospital_id"
  end

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

  create_table "capacities", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "procedure_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "investigation"
  end

  add_index "capacities", ["specialist_id", "procedure_id"], :name => "index_capacities_on_specialist_id_and_procedure_id"

  create_table "clinic_addresses", :force => true do |t|
    t.integer  "clinic_id"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clinic_healthcare_providers", :force => true do |t|
    t.integer  "clinic_id"
    t.integer  "healthcare_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clinic_speaks", :force => true do |t|
    t.integer  "clinic_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clinics", :force => true do |t|
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "postalcode"
    t.string   "city"
    t.string   "province"
    t.string   "phone1"
    t.string   "fax"
    t.text     "status"
    t.text     "interest"
    t.integer  "specialization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "referral_criteria"
    t.text     "referral_process"
    t.string   "responds_via"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.string   "contact_notes"
    t.integer  "status_mask"
    t.text     "limitations"
    t.text     "location_opened"
    t.text     "required_investigations"
    t.text     "not_performed"
    t.boolean  "referral_fax"
    t.boolean  "referral_phone"
    t.string   "referral_other_details"
    t.boolean  "referral_form"
    t.string   "lagtime"
    t.string   "lag_uom"
    t.string   "wait_uom"
    t.boolean  "respond_by_fax"
    t.boolean  "respond_by_phone"
    t.boolean  "respond_by_mail"
    t.boolean  "respond_to_patient"
    t.boolean  "patient_can_book"
    t.text     "red_flags"
    t.boolean  "urgent_fax"
    t.boolean  "urgent_phone"
    t.string   "urgent_other_details"
    t.string   "waittime"
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

  create_table "edits", :force => true do |t|
    t.integer   "specialist_id"
    t.text      "notes"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "edits", ["specialist_id"], :name => "index_edits_on_specialist_id"

  create_table "favorites", :force => true do |t|
    t.integer   "user_id"
    t.integer   "specialist_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "focuses", :force => true do |t|
    t.integer   "clinic_id"
    t.integer   "procedure_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "investigation"
  end

  add_index "focuses", ["clinic_id", "procedure_id"], :name => "index_focuses_on_clinic_id_and_procedure_id"

  create_table "healthcare_providers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hospitals", :force => true do |t|
    t.string    "name"
    t.string    "address1"
    t.string    "address2"
    t.string    "postalcode"
    t.string    "city"
    t.string    "province"
    t.string    "phone1"
    t.string    "fax"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "moderations", :force => true do |t|
    t.integer   "moderatable_id"
    t.string    "moderatable_type",               :null => false
    t.string    "attr_name",        :limit => 60, :null => false
    t.text      "attr_value",                     :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "offices", :force => true do |t|
    t.string    "address1"
    t.string    "address2"
    t.string    "postalcode"
    t.string    "city"
    t.string    "province"
    t.string    "phone1"
    t.string    "fax"
    t.integer   "specialist_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "offices", ["specialist_id"], :name => "index_offices_on_specialist_id"

  create_table "privileges", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "hospital_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "procedures", :force => true do |t|
    t.string   "name"
    t.integer  "specialization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "specialization_level", :default => true
    t.string   "ancestry"
  end

  add_index "procedures", ["ancestry"], :name => "index_procedures_on_ancestry"

  create_table "reviews", :force => true do |t|
    t.string    "item_type",      :null => false
    t.integer   "item_id",        :null => false
    t.string    "whodunnit"
    t.text      "object"
    t.text      "object_changes"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string    "session_id", :null => false
    t.text      "data"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "specialist_addresses", :force => true do |t|
    t.integer  "specialist_id"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specialist_speaks", :force => true do |t|
    t.integer   "specialist_id"
    t.integer   "language_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "specialists", :force => true do |t|
    t.string    "firstname"
    t.string    "lastname"
    t.string    "address1"
    t.string    "address2"
    t.string    "postalcode"
    t.string    "city"
    t.string    "province"
    t.string    "phone1"
    t.string    "fax"
    t.text      "practise_limitations"
    t.text      "interest"
    t.string    "waittime"
    t.integer   "specialization_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "direct_phone"
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
    t.string    "lagtime"
    t.string    "referral_request"
    t.boolean   "patient_can_book",        :default => false
    t.string    "urgent_other_details"
    t.text      "required_investigations"
    t.text      "not_performed"
    t.string    "status_details"
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
    t.boolean   "referral_form"
    t.string    "lag_uom"
    t.string    "wait_uom"
  end

  create_table "specializations", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string    "username"
    t.string    "email"
    t.string    "persistence_token"
    t.string    "crypted_password"
    t.string    "password_salt"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "name"
    t.string    "role"
    t.boolean   "notify"
    t.string    "perishable_token",  :default => "", :null => false
  end

  create_table "versions", :force => true do |t|
    t.string    "item_type",      :null => false
    t.integer   "item_id",        :null => false
    t.string    "event",          :null => false
    t.string    "whodunnit"
    t.text      "object"
    t.timestamp "created_at"
    t.text      "object_changes"
    t.boolean   "to_review"
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
