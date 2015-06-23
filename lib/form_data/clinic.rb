module FormData
  # wrapper class that knows about the structure of the form params hash
  class Clinic
    attr_reader :hsh

    def initialize(hsh)
      @hsh     = hsh
    end

    def to_hash
      hsh
    end

    def clone
      self.class.new hsh.clone
    end

    def update_location_data!(index, data)
      hsh["clinic"]["clinic_locations_attributes"][index.to_s] = data
    end

    def update_location_use_status!(index, status)
      hsh["clinic_location_#{index}"] = status
    end

    def clinic_location_data(location_id)
      clinic_location_attrs[clinic_location_data_index(location_id)]
    end

    def clinic_location_use_status(location_id)
      hsh["clinic_location_#{clinic_location_data_index(location_id)}"]
    end

    def [](key)
      hsh[key]
    end

    private

    def clinic_location_data_index(location_id)
      clinic_location_id_map[location_id]
    end

    # what cloc id maps to what data index?
    def clinic_location_id_map
      @clinic_location_id_map ||= clinic_location_attrs.inject({}) do |memo, (key, value)|
        memo.merge(value["id"] => key)
      end
    end

    def clinic_location_attrs
      hsh["clinic"]["clinic_locations_attributes"].select do |key, attrs|
        # exclude the physician attendance attrs
        !attrs["location_attributes"].nil?
      end
    end
  end
end
