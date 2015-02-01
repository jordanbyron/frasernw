class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :attendances, [:clinic_location_id, :specialist_id]
    add_index :user_controls_specialist_offices, [:specialist_office_id, :user_id], name: "index_ucso_soi_user_id"
    add_index :user_controls_specialist_offices, :user_id, name: "index_ucso_user_id"
    add_index :user_controls_specialist_offices, :specialist_office_id, name: "index_ucso_on_specialist_office_id"
    add_index :featured_contents, :division_id
    add_index :featured_contents, :sc_category_id
    add_index :featured_contents, :sc_item_id
    add_index :featured_contents, :front_id
    add_index :featured_contents, [:front_id, :sc_category_id]
    add_index :featured_contents, [:front_id, :sc_item_id]
    add_index :user_controls_clinic_locations, :user_id
    add_index :user_controls_clinic_locations, :clinic_location_id
    add_index :user_controls_clinic_locations, [:clinic_location_id, :user_id], name: "index_uccl_clinic_l_id_on_user_id"
    add_index :clinic_locations, :clinic_id
    add_index :locations, [:hospital_in_id, :location_in_id]
    add_index :locations, :address_id
    add_index :locations, :location_in_id
    add_index :locations, [:address_id, :location_in_id]
    add_index :locations, [:locatable_id, :location_in_id]
    add_index :reports, :division_id
    add_index :reports, :city_id
    add_index :news_items, :division_id
    add_index :feedback_items, [:item_id, :item_type]
    add_index :feedback_items, :user_id
    add_index :specialist_offices, [:specialist_id, :office_id]
    add_index :specialization_options, [:owner_id, :specialization_id]
    add_index :specialization_options, :specialization_id
    add_index :specialization_options, :owner_id
    add_index :specialization_options, :content_owner_id
    add_index :specialization_options, :division_id
    add_index :specialization_options, :open_to_sc_category_id
    add_index :division_cities, :division_id
    add_index :division_cities, :city_id
    add_index :division_cities, [:city_id, :division_id]
    add_index :sc_item_specialization_procedure_specializations, [:procedure_specialization_id, :sc_item_specialization_id], name: "index_sc_item_s_p_s_on_psid_sc_item_s_id"
    add_index :division_referral_cities, [:city_id, :division_id]
    add_index :division_referral_cities, :division_id
    add_index :division_referral_cities, :city_id
    add_index :clinic_addresses, :clinic_id
    add_index :clinic_addresses, :address_id
    add_index :hospital_addresses, :hospital_id
    add_index :hospital_addresses, :address_id
    add_index :hospital_addresses, [:hospital_id, :address_id]
    add_index :sc_items, :division_id
    add_index :division_display_sc_items, [:division_id, :sc_item_id]
    add_index :division_display_sc_items, :division_id
    add_index :division_display_sc_items, :sc_item_id
    add_index :division_primary_contacts, :division_id
    add_index :division_primary_contacts, :primary_contact_id
    add_index :division_users, :division_id
    add_index :division_users, :user_id
    add_index :user_city_specializations, :user_city_id
    add_index :user_city_specializations, :specialization_id
    add_index :user_city_specializations, [:specialization_id, :user_city_id], name: "index_ucs_on_spec_id_and_ucity_id"
    add_index :specialist_addresses, :specialist_id
    add_index :specialist_addresses, :address_id
    add_index :user_cities, :user_id
    add_index :user_cities, :city_id
    add_index :user_cities, [:user_id, :city_id]
    add_index :division_referral_city_specializations, :division_referral_city_id, name: "index_drcs_on_div_ref_city_id"
    add_index :division_referral_city_specializations, :specialization_id, name: "index_drcs_on_specialization_id"
    add_index :versions, :item_id
    add_index :versions, :created_at
  end
end
