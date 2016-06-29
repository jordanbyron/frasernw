module SeedCreators
  class User < SeedCreator::HandledTable
    Filter = Proc.new{ |user| ["admin", "super"].include?(user.role) }

    Handlers = {
      email: :pass_through,
      persistence_token: :pass_through,
      crypted_password: :pass_through,
      password_salt: :pass_through,
      created_at: :pass_through,
      updated_at: :pass_through,
      name: :pass_through,
      role: :pass_through,
      perishable_token: :pass_through,
      saved_token: :pass_through,
      type_mask: :pass_through,
      last_request_at: :pass_through,
      agree_to_toc: :pass_through,
      active: :pass_through,
      failed_login_count: :pass_through,
      activated_at: :pass_through,
      persist_in_demo: :pass_through,
      last_request_format_key: :pass_through,
      is_developer: :pass_through,
    }
  end
end
