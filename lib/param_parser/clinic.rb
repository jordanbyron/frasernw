module ParamParser
  # Munges params from form before we feed them to #update_attributes
  class Clinic

    attr_reader :params

    def initialize(params)
      @params = params
    end

    def cloned_params
      @cloned_params ||= params.clone
    end

    def exec
      remove_specializations_comments!
      remove_address_comments!
      parse_attendances!
      set_sectors!

      cloned_params
    end

    def parse_attendances!
      attendances_attributes.each do |attrs|
        attrs.each do |k, v|
          if v["is_specialist"] == "0"
            v["specialist_id"] = nil
          end
        end
      end
    end

    def attendances_attributes
      clinic_locations_attributes.map do |attrs|
        attrs["attendances_attributes"]
      end.select(&:present?)
    end

    def set_sectors!
      clinic_locations_attributes.each(&SetSectors)
    end

    def remove_specializations_comments!
      cloned_params["clinic"].delete("specializations_comments")
    end

    def remove_address_comments!
      clinic_locations_attributes.each do |attrs|
        attrs.
          try(:[], "location_attributes").
          try(:delete, "comments")
      end
    end

    def clinic_locations_attributes
      cloned_params["clinic"]["clinic_locations_attributes"].values
    end
  end
end
