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

    def self.label_hash
      select("*").pluck_multiple(:id, label_attr).inject({}) do |memo, record|
        memo.merge(record["id"] => record[label_attr.to_s])
      end
    end

    #default
    def self.label_attr
      :name
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

  class Relation
    # PLUCKED from this blog post!
    # http://meltingice.net/2013/06/11/pluck-multiple-columns-rails/
    def pluck_multiple(*args)
      args.map! do |column_name|
        if column_name.is_a?(Symbol) && column_names.include?(column_name.to_s)
          "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(column_name)}"
        else
          column_name.to_s
        end
      end

      relation = clone
      relation.select_values = args
      klass.connection.select_all(relation.arel).map! do |attributes|
        initialized_attributes = klass.initialize_attributes(attributes)
        attributes.each do |key, attribute|
          attributes[key] = klass.type_cast_attribute(key, initialized_attributes)
        end
      end
    end
  end
end
