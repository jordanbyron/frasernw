module ActiveRecord
  class Base
    def creator
      UnknownUser.new
    end

    def last_updated_at
      updated_at
    end

    def last_updater
      UnknownUser.new
    end

    def class_label
      self.class.name.split_on_capitals
    end

    def numbered_label
      "#{class_label} ##{self.id}"
    end
  end
end
