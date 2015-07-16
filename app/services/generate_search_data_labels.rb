module GenerateSearchDataLabels
  def self.generators
    {
      :groups => Proc.new {
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

        group_data = {
          order_map["Specializations"] => "Specialties",
          order_map["Specialists"] => "Specialists",
          order_map["Clinics"] => "Clinics",
          order_map["Content"] => "Content",
          order_map["Procedures"] => "Areas of Practice",
          order_map["Hospitals"] => "Hospitals",
          order_map["Languages"] => "Languages"
        }

        ScCategory.all.each do |category|
          group_data[ order_map[category.name] ] = category.full_name
        end

        group_data
      },
      :urls => Proc.new {
        url_data = {
          order_map["Specializations"]  => "specialties",
          order_map["Specialists"]  => "specialists",
          order_map["Clinics"]  => "clinics",
          order_map["Content"]  => "content_categories",
          order_map["Procedures"]  => "areas_of_practice",
          order_map["Hospitals"]  => "hospitals",
          order_map["Languages"]  => "languages"
        }

        ScCategory.all.each do |category|
          url_data[ order_map[category.name] ] = "content_items"
        end

        url_data
      },
      :specializations => Proc.new {
        specialization_data = Hash.new

        Specialization.all.each do |specialization|
          specialization_data[specialization.id] = specialization.name
        end

        specialization_data
      },
      :cities => Proc.new {
        city_data = Hash.new

        City.all.each do |city|
          city_data[city.id] = city.name
        end

        city_data

      },
      :statuses => Proc.new {
        status_data = Hash.new

        Specialist::STATUS_CLASS_HASH.each do |key, value|
          status_data[value] = key
        end

        status_data
      }
    }
  end
end
