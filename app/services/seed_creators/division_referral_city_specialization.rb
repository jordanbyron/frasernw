module SeedCreators
  class DivisionReferralCitySpecialization < SeedCreator::HandledTable
    Handlers = {
      division_referral_city_id: :pass_through,
      specialization_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
