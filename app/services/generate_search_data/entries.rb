module GenerateSearchData
  # aka specialists and clinics
  class Entries
    attr_reader :division

    def initialize(division)
      @division = division
    end

    def exec
      filter(sort(from_specializations))
    end

    def from_specializations
      Specialization.all.inject([]) do |memo, specialization|
        memo + from_specialization(specialization)
      end
    end

    def from_specialization(specialization)
      GenerateSearchData::Entries::BySpecialization.new(
        division,
        specialization
      ).exec
    end

    # sort by group id then item id
    def sort(entries)
      entries.sort_by do |entry|
        [ entry["go"], entry["id"] ]
      end
    end

    # filter out duplicates (records with the same id and type)
    def filter(entries)
      entries.uniq do |entry|
        [ entry["go"], entry["id"] ]
      end
    end

    class BySpecialization
      attr_reader :division, :specialization

      def initialize(division, specialization)
        @division = division
        @specialization = specialization
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

        specialists = Specialist.not_in_progress_for_division_local_referral_area_and_specialization(division, specialization)
        clinics = Clinic.not_in_progress_for_division_local_referral_area_and_specialization(division, specialization)

        specialists.each do |specialist|

          entry = {
            "n" => specialist.billing_number_padded ? specialist.name + " - MSP #" + specialist.billing_number_padded: specialist.name,
            "sp" => specialist.specialist_specializations.map { |ss| ss.specialization_id },
            "c" => specialist.cities_for_display.map{ |city| city.id },
            "st" => specialist.status_class_hash,
            "id" => specialist.id,
            "go" => order_map["Specialists"]
          }
          search_data << entry
        end

        clinics.each do |clinic|

          entry = {
            "n" => clinic.name,
            "sp" => clinic.clinic_specializations.map{ |cs| cs.specialization_id },
            "c" => clinic.cities.map{ |city| city.id },
            "st" => clinic.status_class_hash,
            "id" => clinic.id,
            "go" => order_map["Clinics"]
          }
          search_data << entry
        end

        search_data
      end
    end
  end
end
