module Serialized
  def self.regenerate_all
    GENERATORS.keys.each{ |key| regenerate(key) }
  end

  def self.cache_key(generator_key)
    "serialized:#{generator_key}"
  end

  def self.fetch(generator_key)
    Rails.cache.fetch(cache_key(generator_key)) do
      self.generate(generator_key)
    end
  end

  def self.generate(generator_key)
    GENERATORS[generator_key].call
  end

  def self.regenerate(generator_key)
    Rails.cache.write(
      cache_key(generator_key),
      self.generate(generator_key)
    )
  end

  GENERATORS = {
    content_items: Module.new do
      def self.call
        ScItem.includes(:sc_category, :division, :divisions_sharing, :specializations).inject({}) do |memo, item|
          memo.merge(item.id => {
            availableToDivisionIds: item.available_to_divisions.map(&:id),
            specializationIds: item.specializations.map(&:id),
            title: item.title,
            categoryId: item.sc_category.id,
            categoryIds: [ item.sc_category, item.sc_category.ancestors ].flatten.map(&:id),
            content: (item.markdown_content.present? ? BlueCloth.new(item.markdown_content).to_html : ""),
            resolvedUrl: item.resolved_url,
            canEmail: item.can_email?,
            id: item.id,
            isNew: item.new?,
            isInProgress: item.in_progress,
            isSharedCare: item.shared_care?,
            typeMask: item.type_mask
          })
        end
      end
    end,
    specialists: Module.new do
      def self.call
        Specialist.includes_specialization_page.all.inject({}) do |memo, specialist|
          memo.merge(specialist.id => {
            id: specialist.id,
            name: specialist.name,
            firstName: specialist.firstname,
            lastName: specialist.lastname,
            statusIconClasses: specialist.status_class,
            statusClassKey: specialist.status_class_hash,
            divisionIds: specialist.divisions.map(&:id),
            waittime: masked_waittime(specialist),
            cityIds: specialist.cities.reject{ |city| city.hidden }.map(&:id),
            collectionName: "specialists",
            procedureIds: specialist.procedure_ids_with_parents,
            respondsWithin: specialist.lagtime_mask,
            acceptsReferralsViaPhone: specialist.referral_phone,
            patientsCanBook: specialist.patient_can_book?,
            sex: specialist.sex.downcase,
            scheduledDayIds: specialist.day_ids,
            languageIds: specialist.languages.map(&:id),
            hospitalIds: specialist.hospitals.map(&:id),
            clinicIds: specialist.clinics.map(&:id),
            specializationIds: specialist.specializations.map(&:id),
            customLagtimes: custom_lagtimes(specialist),
            isGp: specialist.is_gp,
            isNew: specialist.new?,
            isInProgress: specialist.in_progress,
            createdAt: specialist.created_at.to_date.to_s,
            updatedAt: specialist.updated_at.to_date.to_s
          })
        end
      end

      def self.masked_waittime(specialist)
        if specialist.show_wait_time_in_table?
          specialist.waittime
        else
          nil
        end
      end

      def self.custom_lagtimes(specialist)
        specialist.capacities.inject({}) do |memo, capacity|
          if capacity.lagtime_mask
            memo.merge(capacity.procedure.id => capacity.lagtime_mask)
          else
            memo
          end
        end
      end
    end,
    clinics: Module.new do
      def self.call
        Clinic.
          includes([:procedures, :specializations, :languages]).
          includes_location_data.
          includes_location_schedules.
          all.
          inject({}) do |memo, clinic|
          memo.merge(clinic.id => {
            id: clinic.id,
            name: clinic.name,
            statusIconClasses: clinic.status_class,
            statusClassKey: clinic.status_class_hash,
            waittime: masked_waittime(clinic),
            cityIds: clinic.cities.reject{ |city| city.hidden }.map(&:id),
            collectionName: "clinics",
            procedureIds: clinic.procedure_ids_with_parents,
            respondsWithin: clinic.lagtime_mask,
            acceptsReferralsViaPhone: clinic.referral_phone,
            patientsCanBook: clinic.patient_can_book?,
            scheduledDayIds: clinic.scheduled_day_ids,
            languageIds: clinic.languages.map(&:id),
            divisionIds: clinic.divisions.map(&:id),
            specializationIds: clinic.specializations.map(&:id),
            wheelchairAccessible: clinic.wheelchair_accessible?,
            customLagtimes: custom_lagtimes(clinic),
            private: clinic.private?,
            careProviderIds: clinic.healthcare_providers.map(&:id),
            isNew: clinic.new?,
            isInProgress: clinic.in_progress,
            createdAt: clinic.created_at.to_date.to_s,
            updatedAt: clinic.updated_at.to_date.to_s
          })
        end
      end

      def self.masked_waittime(clinic)
        if clinic.show_wait_time_in_table?
          clinic.waittime
        else
          nil
        end
      end

      def self.custom_lagtimes(clinic)
        clinic.focuses.inject({}) do |memo, focus|
          if focus.lagtime_mask
            memo.merge(focus.procedure.id => focus.lagtime_mask)
          else
            memo
          end
        end
      end
    end,
    content_categories: Module.new do
      def self.call
        ScCategory.all.inject({}) do |memo, category|
          memo.merge(category.id => {
            id: category.id,
            name: category.name,
            displayMask: category.display_mask,
            subtreeIds: category.subtree.map(&:id),
            ancestry: category.ancestry,
            componentType: component_type(category)
          })
        end
      end

      def self.component_type(category)
        (category.filterable_on_specialty_pages? ? "FilterTable" : "InlineArticles")
      end
    end,
    specializations: Proc.new do
      Specialization.includes(:specialization_options).all.inject({}) do |memo, specialization|
        memo.merge(specialization.id => {
          id: specialization.id,
          name: specialization.name,
          assumedList: specialization.procedure_specializations.assumed_specialist.
            reject{ |ps| ps.parent.present? }.
            sort{ |a,b| a.procedure.name <=> b.procedure.name }.
            map{ |ps| ps.procedure.name.uncapitalize_first_letter },
          memberName: specialization.member_name,
          membersName: specialization.member_name.pluralize,
          nestedProcedureIds: Module.new do
            def self.call(specialization)
              transform_nested_procedure_specializations(
                specialization.procedure_specializations.includes(:procedure).arrange
              )
            end

            def self.transform_nested_procedure_specializations(procedure_specializations)
              procedure_specializations.inject({}) do |memo, (ps, children)|
                memo.merge({
                  ps.procedure.id => {
                    focused: ps.focused?,
                    assumed: {
                      clinics: ps.assumed_clinic?,
                      specialists: ps.assumed_specialist?
                    },
                    children: transform_nested_procedure_specializations(children)
                  }
                })
              end
            end
          end.call(specialization)
        })
      end
    end,
    healthcare_providers: Proc.new do
      HealthcareProvider.all.inject({}) do |memo, provider|
        memo.merge(provider.id => {
          name: provider.name
        })
      end
    end,
    hospitals: Proc.new do
      Hospital.all.inject({}) do |memo, hospital|
        memo.merge(hospital.id => {
          name: hospital.name
        })
      end
    end,
    cities: Proc.new do
      City.not_hidden.inject({}) do |memo, city|
        memo.merge(city.id => {
          id: city.id,
          name: city.name
        })
      end
    end,
    languages: Proc.new do
      Language.all.inject({}) do |memo, language|
        memo.merge(language.id => {
          name: language.name
        })
      end
    end,
    procedures: Proc.new do
      Procedure.all.inject({}) do |memo, procedure|
        memo.merge(procedure.id => {
          nameRelativeToParents: procedure.try(:name_relative_to_parents),
          name: procedure.name
        })
      end
    end,
    divisions: Proc.new do
      Division.standard.all.inject({}) do |memo, division|
        memo.merge(division.id => {
          id: division.id,
          name: division.name
        })
      end
    end,
    referral_forms: Proc.new do
      ReferralForm.all.inject({}) do |memo, form|
        memo.merge(form.id => {
          id: form.id,
          filename: form.form_file_name,
          referrableType: form.referrable_type,
          referrableId: form.referrable_id
        })
      end
    end,
    respondsWithinOptions: Proc.new do
      Clinic::LAGTIME_HASH.inject({}) do |memo, (key, value)|
        memo.merge(key.to_i => value)
      end.merge(0 => "Any timeframe")
    end,
    respondsWithinSummaryLabels: Proc.new do
      Clinic::LAGTIME_HASH.inject({}) do |memo, (key, value)|
        label = begin
          if key == 1
            "by phone when office calls for appointment"
          elsif key == 2
            "within one week"
          else
            "within #{value}"
          end
        end

        memo.merge({key => label})
      end
    end
  }
end
