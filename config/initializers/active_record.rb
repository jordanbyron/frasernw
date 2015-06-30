module ActiveRecord
  class Base
    def last_updated_at
      updated_at
    end

    def last_updater
      UnknownUser.new
    end
  end
end
