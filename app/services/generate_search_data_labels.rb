module GenerateSearchDataLabels
  ORDER_MAP = {
    "Specializations" => "1",
    "Specialists" => "2",
    "Clinics" => "3",
    "Content" => "4",
    "Procedures" => "5",
    "Hospitals" => "6",
    "Languages" => "7"
  }


  def self.generators
    {
      :groups => Proc.new {

        ScCategory.all.each do |category|
          ORDER_MAP[ category.name ] = ( ORDER_MAP.length + 1 ).to_s
        end

        group_data = {
          ORDER_MAP["Specializations"] => "Specialties",
          ORDER_MAP["Specialists"] => "Specialists",
          ORDER_MAP["Clinics"] => "Clinics",
          ORDER_MAP["Content"] => "Content",
          ORDER_MAP["Procedures"] => "Areas of Practice",
          ORDER_MAP["Hospitals"] => "Hospitals",
          ORDER_MAP["Languages"] => "Languages"
        }

        ScCategory.all.each do |category|
          group_data[ ORDER_MAP[category.name] ] = category.full_name
        end

        group_data
      },
      :urls => Proc.new {
        url_data = {
          ORDER_MAP["Specializations"]  => "specialties",
          ORDER_MAP["Specialists"]  => "specialists",
          ORDER_MAP["Clinics"]  => "clinics",
          ORDER_MAP["Content"]  => "content_categories",
          ORDER_MAP["Procedures"]  => "areas_of_practice",
          ORDER_MAP["Hospitals"]  => "hospitals",
          ORDER_MAP["Languages"]  => "languages"
        }

        ScCategory.all.each do |category|
          url_data[ ORDER_MAP[category.name] ] = "content_items"
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
