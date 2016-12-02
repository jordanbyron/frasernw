module ActiveRecord
  class Base

    def self.random(column)
      unscoped.select(column).first(order: "RANDOM()")[column]
    end

    def self.random_id
      random(:id)
    end

    def self.safe_find(id)
      where(id: id).first
    end

    def self.pluck_to_hash(keys)
      pluck(*keys).map{ |plucked_attribute| Hash[keys.zip(plucked_attribute)] }
    end

    def self.id_hash(value)
      pluck(:id).inject({}) do |memo, id|
        memo.merge(id => value)
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

    def last_update_editor
      ""
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

    def valid_tokens
      [ saved_token ]
    end
  end
end
