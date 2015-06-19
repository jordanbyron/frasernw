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
      remove_office_comments!

      cloned_params
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
