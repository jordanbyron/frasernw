module SeedCreators
  class Newsletter < SeedCreator::HandledTable
    Handlers = {
      month_key: :pass_through,
      document_file_name: Proc.new { "demo_filename" },
      document_content_type: Proc.new { "demo content type" },
      document_file_size: :pass_through,
      document_updated_at: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
