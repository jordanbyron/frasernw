require 'lib/param_parser/specialist'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'

RSpec.describe ParamParser::Clinic do
  params = {"utf8"=>"✓",
 "_method"=>"put",
 "authenticity_token"=>"SYZjIP9otsCZKl+VqKkxQPuDEdlN3TPafAL9+PF56lg=",
 "specialist"=>
  {"firstname"=>"asdgag",
   "lastname"=>"asdgag",
   "goes_by_name"=>"",
   "sex_mask"=>"1",
   "billing_number"=>"06605",
   "categorization_mask"=>"1",
   "is_gp"=>"0",
   "specialization_ids"=>["28", ""],
   "specializations_comments"=>"asdgasgadsgasdg",
   "hospital_clinic_details"=>"",
   "address_updates"=>"my address changed!!!!",
   "specialist_offices_attributes"=>
    {"0"=>
      {"phone"=>"asdgag",
       "phone_extension"=>"",
       "fax"=>"asdgagdasg",
       "direct_phone"=>"",
       "direct_phone_extension"=>"",
       "email"=>"",
       "public_email"=>"",
       "url"=>"asdasdasfasf",
       "office_id"=>"495",
       "comments"=>"asdgasdgdsagsdagsdgasdg",
       "open_saturday"=>"0",
       "open_sunday"=>"0",
       "location_opened"=>"Prior to 2010",
       "sector_mask"=>"1",
       "phone_schedule_attributes"=>
        {"monday_attributes"=>
          {"scheduled"=>"1",
           "from(1i)"=>"2000",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"10",
           "from(5i)"=>"00",
           "to(1i)"=>"2000",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"17",
           "to(5i)"=>"30",
           "break_from(1i)"=>"2000",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"01",
           "break_from(5i)"=>"30",
           "break_to(1i)"=>"2000",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"14",
           "break_to(5i)"=>"30",
           "id"=>"1261"},
         "tuesday_attributes"=>
          {"scheduled"=>"1",
           "from(1i)"=>"2000",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"10",
           "from(5i)"=>"00",
           "to(1i)"=>"2000",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"17",
           "to(5i)"=>"30",
           "break_from(1i)"=>"2000",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"01",
           "break_from(5i)"=>"30",
           "break_to(1i)"=>"2000",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"17",
           "break_to(5i)"=>"30",
           "id"=>"1262"},
         "wednesday_attributes"=>
          {"scheduled"=>"1",
           "from(1i)"=>"2000",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"10",
           "from(5i)"=>"00",
           "to(1i)"=>"2000",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"17",
           "to(5i)"=>"30",
           "break_from(1i)"=>"2000",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"01",
           "break_from(5i)"=>"30",
           "break_to(1i)"=>"2000",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"17",
           "break_to(5i)"=>"30",
           "id"=>"1263"},
         "thursday_attributes"=>
          {"scheduled"=>"1",
           "from(1i)"=>"2000",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"10",
           "from(5i)"=>"00",
           "to(1i)"=>"2000",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"17",
           "to(5i)"=>"30",
           "break_from(1i)"=>"2000",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"01",
           "break_from(5i)"=>"30",
           "break_to(1i)"=>"2000",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"17",
           "break_to(5i)"=>"30",
           "id"=>"1264"},
         "friday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"1265"},
         "saturday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"1266"},
         "sunday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"1267"},
         "id"=>"181"},
       "id"=>"644"},
     "1"=>
      {"phone"=>"",
       "phone_extension"=>"",
       "fax"=>"",
       "direct_phone"=>"",
       "direct_phone_extension"=>"",
       "email"=>"",
       "public_email"=>"",
       "url"=>"",
       "office_id"=>"",
       "comments"=>"",
       "open_saturday"=>"0",
       "open_sunday"=>"0",
       "location_opened"=>"",
       "sector_mask"=>"4",
       "phone_schedule_attributes"=>
        {"monday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"16773"},
         "tuesday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"16774"},
         "wednesday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"16775"},
         "thursday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"16776"},
         "friday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"16777"},
         "saturday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"16778"},
         "sunday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"16779"},
         "id"=>"2397"},
       "id"=>"2335"},
     "2"=>
      {"phone"=>"",
       "phone_extension"=>"",
       "fax"=>"",
       "direct_phone"=>"",
       "direct_phone_extension"=>"",
       "email"=>"",
       "public_email"=>"",
       "url"=>"",
       "office_id"=>"",
       "comments"=>"",
       "open_saturday"=>"0",
       "open_sunday"=>"0",
       "location_opened"=>"",
       "sector_mask"=>"4",
       "phone_schedule_attributes"=>
        {"monday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"27600"},
         "tuesday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"27601"},
         "wednesday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"27602"},
         "thursday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"27603"},
         "friday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"27604"},
         "saturday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"27605"},
         "sunday_attributes"=>
          {"scheduled"=>"0",
           "from(1i)"=>"1",
           "from(2i)"=>"1",
           "from(3i)"=>"1",
           "from(4i)"=>"",
           "from(5i)"=>"",
           "to(1i)"=>"1",
           "to(2i)"=>"1",
           "to(3i)"=>"1",
           "to(4i)"=>"",
           "to(5i)"=>"",
           "break_from(1i)"=>"1",
           "break_from(2i)"=>"1",
           "break_from(3i)"=>"1",
           "break_from(4i)"=>"",
           "break_from(5i)"=>"",
           "break_to(1i)"=>"1",
           "break_to(2i)"=>"1",
           "break_to(3i)"=>"1",
           "break_to(4i)"=>"",
           "break_to(5i)"=>"",
           "id"=>"27606"},
         "id"=>"3972"},
       "id"=>"3377"}},
   "address_update"=>"",
   "contact_name"=>"asdgagasdg",
   "contact_email"=>"asdgagadsg",
   "contact_phone"=>"asdgagdasgasgas",
   "contact_notes"=>"",
   "status_mask"=>"1",
   "unavailable_from(1i)"=>"2012",
   "unavailable_from(2i)"=>"4",
   "unavailable_from(3i)"=>"4",
   "unavailable_to(1i)"=>"2012",
   "unavailable_to(2i)"=>"4",
   "unavailable_to(3i)"=>"4",
   "status_details"=>"",
   "practise_limitations"=>"",
   "language_ids"=>["1", "21", "6", ""],
   "interpreter_available"=>"0",
   "required_investigations"=>"",
   "interest"=>"Food allergies, Urticaria",
   "not_performed"=>"No drug or latex testing.",
   "referral_fax"=>"0",
   "referral_phone"=>"1",
   "referral_other_details"=>"",
   "referral_details"=>"",
   "referral_form_mask"=>"2",
   "lagtime_mask"=>"1",
   "waittime_mask"=>"5",
   "respond_by_fax"=>"0",
   "respond_by_phone"=>"1",
   "respond_by_mail"=>"0",
   "respond_to_patient"=>"0",
   "patient_can_book_mask"=>"1",
   "red_flags"=>"",
   "urgent_fax"=>"1",
   "urgent_phone"=>"1",
   "urgent_other_details"=>"",
   "urgent_details"=>"If faxing, mark URGENT.",
   "patient_instructions"=>
    "asdgasgdasgasdg.",
   "cancellation_policy"=>
    "asdgasgdasgasg",
   "hospital_ids"=>[""],
   "clinic_location_ids"=>[""],
   "admin_notes"=>"Updated by secret edit link Mar 4/14"},
 "location_0"=>"In an office",
 "location_1"=>"Not used",
 "location_2"=>"Not used",
 "specialist_areas_of_practice_mapped"=>{"22796"=>"1", "2830"=>"1", "2854"=>"1", "5112"=>"1", "11599"=>"1", "28268"=>"1", "8886"=>"1"},
 "specialist_areas_of_practice_investigations"=>
  {"22796"=>"", "2876"=>"", "3085"=>"", "2830"=>"", "2854"=>"", "3108"=>"", "5112"=>"8 years and over", "11639"=>"", "11599"=>"", "28268"=>"", "11479"=>"", "8886"=>""},
 "commit"=>"Update Specialist",
 "action"=>"accept",
 "controller"=>"specialists",
 "id"=>"532"}

  it "removes the 'specializations_comments' key from the params hash" do
    expect(
      ParamParser::Specialist.new(params).exec["specialist"]["specializations_comments"]
    ).to eq(nil)
  end

  it "removes the 'address_updates' key from the params hash" do
    expect(
      ParamParser::Specialist.new(params).exec["specialist"]["address_updates"]
    ).to eq(nil)
  end

  it "removes the address 'comments' key from each of the clinic locations attributes" do
    expect(
      ParamParser::Specialist.new(params).exec["specialist"]["specialist_offices_attributes"]["0"]["comments"]
    ).to eq(nil)
  end
end
