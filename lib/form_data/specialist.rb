module FormData
  # wrapper class that knows about the structure of the form params hash
  class Specialist
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

    def has_office_attrs?
      !(hsh["specialist"].nil?) && !(hsh["specialist"]["specialist_offices_attributes"].nil?)
    end

    def update_specialist_office_data!(index, data)
      hsh["specialist"]["specialist_offices_attributes"][index.to_s] = data
    end

    def update_specialist_office_use_status!(index, status)
      hsh["location_#{index}"] = status
    end

    def specialist_office_data(specialist_office_id)
      specialist_office_attrs[specialist_office_data_index(specialist_office_id)]
    end

    def specialist_office_use_status(specialist_office_id)
      hsh["location_#{specialist_office_data_index(specialist_office_id)}"]
    end

    def [](key)
      hsh[key]
    end

    private

    def specialist_office_data_index(specialist_office_id)
      specialist_office_id_map[specialist_office_id]
    end

    # what cloc id maps to what data index?
    def specialist_office_id_map
      @specialist_office_id_map ||= specialist_office_attrs.inject({}) do |memo, (key, value)|
        memo.merge(value["id"] => key)
      end
    end

    def specialist_office_attrs
      hsh["specialist"]["specialist_offices_attributes"].select do |key, attrs|
        # exclude the physician attendance attrs
        !attrs["phone_schedule_attributes"].nil?
      end
    end
  end
end
