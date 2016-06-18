module SeedCreators
  class DivisionUser < SeedCreator::HandledTable
    Filter = Proc.new{ |division_user| division_user.user.admin_or_super? }

    Handlers = {
      division_id: :pass_through,
      user_id: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
    }
  end
end
