module FormDataMatcher
  # takes old form data and ensures it matches with the current
  # layout of the form ( to compare/overlay/diff )
  class Clinic
    attr_reader :form_data, :clinic

    def initialize(form_data_hsh, clinic)
      @form_data = FormData::Clinic.new(form_data_hsh)
      @clinic    = clinic
    end

    def exec
      # account for malformed ReviewItems with referral form data saved as the base object on them
      return form_data unless form_data.has_location_attrs?

      rearrange_clinic_location_attrs!

      cloned_form_data
    end

    def cloned_form_data
      @cloned_form_data ||= form_data.clone
    end

    def rearrange_clinic_location_attrs!
      ordered_clinic_location_ids.each_with_index do |clinic_location_id, index|
        cloned_form_data.update_location_data!(
          index,
          form_data.clinic_location_data(clinic_location_id)
        )
        cloned_form_data.update_location_use_status!(
          index,
          form_data.clinic_location_use_status(clinic_location_id)
        )
      end
    end

    def ordered_clinic_location_ids
      clinic.ordered_clinic_locations.map(&:id).map(&:to_s)
    end
  end
end
