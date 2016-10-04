module SeedCreators
  class ReferralForm < SeedCreator::HandledTable
    Handlers = {
      referrable_type: :pass_through,
      referrable_id: :pass_through,
      description: Proc.new{ "Referral Form Title" },
      form_file_name: Proc.new{ "demo_form" },
      form_content_type: Proc.new{ "PDF" },
      form_file_size: :pass_through,
      form_updated_at: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
