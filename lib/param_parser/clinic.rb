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
      set_sectors!

      cloned_params
    end

    def set_sectors!
      clinic_locations_attributes.each do |attrs|
        next unless attrs.is_a?(Hash)
        next unless ["0", "1"].include?(attrs["sector_info_available"])

        if attrs["sector_info_available"] == "0"
        # 'nil' means 'unknown' on a boolean field
          ClinicLocation::SECTORS.each do |sector|
            attrs[sector.to_s] = nil
          end
        end

        # cleanup
        attrs.delete("sector_info_available")
      end
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
