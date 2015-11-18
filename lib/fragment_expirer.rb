module FragmentExpirer
  include ActionController::Caching::Actions
  include ActionController::Caching::Fragments

  # The following methods are defined to fake out the ActionController
  # requirements of the Rails cache

  def cache_store
    ActionController::Base.cache_store
  end

  def self.benchmark( *params )
    yield
  end

  def cache_configured?
    true
  end
end
