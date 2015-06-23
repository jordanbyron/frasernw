module FormDataMatcher
  # takes old form data and ensures it matches with the current
  # layout of the form ( to compare/overlay/diff )
  class Clinic
    attr_reader :form_data, :clinic

    def initialize(form_data, clinic)
      @form_data = form_data
      @clinic = clinic
    end

    def exec
      rearrange_clinic_location_attrs!

      cloned_form_data
    end

    def cloned_form_data
      @cloned_form_data ||= form_data.clone
    end

    def rearrange_clinic_location_attrs!
      clinic_location_ids.each_with_index do |id, index|
        cloned_form_data["clinic"]["clinic_locations_attributes"][index.to_s] =
          clinic_location_data(id)
        cloned_form_data["clinic_location_#{index}"] =
          clinic_location_use_status(id)
      end
    end

    def clinic_location_use_status(location_id)
      form_data["clinic_location_#{form_data_location_index(location_id)}"]
    end

    def clinic_location_data(location_id)
      clinic_location_attrs[form_data_location_index(location_id)]
    end

    def form_data_location_index(location_id)
      # puts "location_index: #{id_map[location_id]}"

      id_map[location_id]
    end

    def clinic_location_attrs
      form_data["clinic"]["clinic_locations_attributes"].select do |key, attrs|
        # exclude the physician attendance attrs
        !attrs["location_attributes"].nil?
      end
    end

    def id_map
      id_map = clinic_location_attrs.inject({}) do |memo, (key, value)|
        memo.merge(value["id"] => key)
      end

      id_map
    end

    def clinic_location_ids
      @clinic_location_ids = clinic.ordered_clinic_locations.
        map(&:id).
        map(&:to_s)
    end
  end
end
