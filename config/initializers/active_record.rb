module ActiveRecord
  class Base
    def self.id_hash
      all.inject({}) do |memo, record|
        if block_given?
          memo.merge(record.id => yield(record))
        else
          memo.merge(record.id => record.name)
        end
      end
    end

    def creator
      UnknownUser.new
    end

    def post_creation_version
      if created_at == updated_at
        self
      else
        nil
      end
    end

    def last_updated_at
      updated_at
    end

    def last_updater
      UnknownUser.new
    end

    def last_update_changeset
      nil
    end

    def class_label
      self.class.name.split_on_capitals
    end

    def numbered_label
      "#{class_label} ##{self.id}"
    end
  end
end
