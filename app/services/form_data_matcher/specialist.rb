module FormDataMatcher
  # takes old form data and ensures it matches with the current
  # layout of the form ( to compare/overlay/diff )
  class Specialist
    attr_reader :form_data, :specialist

    def initialize(form_data_hsh, specialist)
      @form_data  = FormData::Specialist.new(form_data_hsh)
      @specialist = specialist
    end

    def exec
      # account for malformed ReviewItems with referral form data saved as the base object on them
      return form_data unless form_data.has_office_attrs?

      rearrange_specialist_office_attrs!

      cloned_form_data
    end

    def cloned_form_data
      @cloned_form_data ||= form_data.clone
    end

    def rearrange_specialist_office_attrs!
      ordered_specialist_office_ids.each_with_index do |specialist_office_id, index|
        cloned_form_data.update_specialist_office_data!(
          index,
          form_data.specialist_office_data(specialist_office_id)
        )
      end
    end

    def ordered_specialist_office_ids
      specialist.ordered_specialist_offices.map(&:id).map(&:to_s)
    end
  end
end
