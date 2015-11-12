module TokenAccessible
  extend ActiveSupport::Concern

  included do
    has_many :secret_tokens, as: :accessible
  end

  def valid_secret_edit_links
    secret_tokens.map(&:as_hash)
  end

end
