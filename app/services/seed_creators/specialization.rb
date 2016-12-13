module SeedCreators
  class Specialization < SeedCreator::HandledTable
    Handlers = {
      name: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      saved_token: Proc.new{ "demo_saved_token"},
      member_name: :pass_through,
      deprecated_open_to_clinic_tab: :pass_through,
      member_tag: :pass_through,
      global_member_tag: :pass_through,
      mask_filters_by_referral_area: :pass_through,
      members_are_physicians: :pass_through,
    }
  end
end
