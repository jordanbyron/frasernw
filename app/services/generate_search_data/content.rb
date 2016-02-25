module GenerateSearchData
  class Content

    attr_reader :division

    def initialize(division)
      @division = division
    end

    def exec
      search_data = Array.new

      order_map = {
        "Specializations" => "1",
        "Specialists" => "2",
        "Clinics" => "3",
        "Content" => "4",
        "Procedures" => "5",
        "Hospitals" => "6",
        "Languages" => "7"
      }

      ScCategory.all.each do |category|
        order_map[ category.name ] = ( order_map.length + 1 ).to_s
      end

      ScCategory.all.each do |category|
        category.all_sc_items_in_divisions([division], :exclude_subcategories => true).reject{ |item| !item.searchable? || item.in_progress }.each do |item|
          entry = {
            "n" => item.title,
            "sp" => item.specializations.not_in_progress_for_divisions([division]).uniq.collect{ |s| s.id },
            "id" => item.id,
            "go" => order_map[category.name],
            "rc" => root_category_id(item)
          }
          search_data << entry
        end
      end

      search_data
    end

    PEARLS_ID = 3
    RED_FLAGS_ID = 4
    PHYSICIAN_RESOURCES_ID = 11
    def root_category_id(sc_item)
      if [PEARLS_ID, RED_FLAGS_ID].include?(sc_item.root_category.id)
        PHYSICIAN_RESOURCES_ID
      else
        sc_item.root_category.id
      end
    end
  end
end
