module SeedCreators
  class ScItem < SeedCreator::HandledTable
    Filter = Proc.new{ |sc_item| sc_item.demoable  }

    Handlers = {
      sc_category_id: :pass_through,
      title: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      type_mask: :pass_through,
      url: :pass_through,
      markdown_content: :pass_through,
      searchable: :pass_through,
      shared_care: :pass_through,
      document_file_name: :pass_through,
      document_content_type: :pass_through,
      document_file_size: :pass_through,
      document_updated_at: :pass_through,
      division_id: :pass_through,
      borrowable: :pass_through,
      evidence_id: :pass_through,
      demoable: :pass_through,
      can_email: :pass_through
    }
  end
end
