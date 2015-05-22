module Analytics
  class AbstractTable < Table
    def search(query)
      rows.select { |row| row.lazy_match? query }
    end

    def user_type_divisions(key)
      search(user_type_key: key).reject do |row|
        row[:division_id] == nil
      end
    end

    def total
      search(user_type_key: nil, division_id: nil)
    end

    def total_for_user_type(key)
      search(user_type_key: key, division_id: nil)
    end

    def by_division
      search(user_type_key: nil).reject do |row|
        row[:division_id] == nil
      end
    end
  end
end
