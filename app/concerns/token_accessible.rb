module TokenAccessible
  extend ActiveSupport::Concern

  included do
    has_many :secret_tokens, as: :accessible
  end

  def valid_secret_edit_links(host)
    secret_tokens.not_expired.map{|token| token.as_hash(host) }
  end

end
