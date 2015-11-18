module ParamParser
  # Munges params from form before we feed them to #update_attributes
  class Specialist

    attr_reader :params

    def initialize(params)
      @params = params
    end

    def cloned_params
      @cloned_params ||= params.clone
    end

    def exec
      remove_specializations_comments!
      remove_address_updates!
      remove_office_comments!
      set_sectors!

      cloned_params
    end

    def set_sectors!
      specialist_offices_attributes.each(&SetSectors)
    end

    def remove_address_updates!
      cloned_params["specialist"].delete("address_updates")
    end

    def remove_specializations_comments!
      cloned_params["specialist"].delete("specializations_comments")
    end

    def remove_office_comments!
      specialist_offices_attributes.each do |attrs|
        attrs.try(:delete, "comments")
      end
    end

    def specialist_offices_attributes
      cloned_params["specialist"]["specialist_offices_attributes"].values
    end
  end
end
