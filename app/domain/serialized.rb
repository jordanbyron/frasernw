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
        ScItem.includes(:sc_category, :division, :divisions_sharing, :specializations).map do |item|
          {
            availableToDivisionIds: item.available_to_divisions.map(&:id),
            specializationIds: item.specializations.map(&:id),
            title: item.title,
            categoryId: item.sc_category.id,
            content: (item.markdown_content.present? ? BlueCloth.new(item.markdown_content).to_html : ""),
            resolvedUrl: item.resolved_url,
            canEmail: item.can_email_document,
            id: item.id,
            isNew: item.new?,
            isInProgress: item.in_progress
          }
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
            waittime: masked_waittime(specialist),
            cityIds: specialist.cities.reject{ |city| city.hidden }.map(&:id),
            collectionName: collection_name(specialist),
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
            isInProgress: specialist.in_progress
          })
        end
      end

      def self.collection_name(specialist)
        if specialist.specializations.any?
          specialist.specializations.first.label_name.downcase.pluralize
        else
          ""
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
            specializationIds: clinic.specializations.map(&:id),
            wheelchairAccessible: clinic.wheelchair_accessible?,
            customLagtimes: custom_lagtimes(clinic),
            private: clinic.private?,
            careProviderIds: clinic.healthcare_providers.map(&:id),
            isNew: clinic.new?,
            isInProgress: clinic.in_progress
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
          name: specialization.name,
          assumedList: specialization.procedure_specializations.assumed_specialist.
            reject{ |ps| ps.parent.present? }.
            sort{ |a,b| a.procedure.name <=> b.procedure.name }.
            map{ |ps| ps.procedure.name.uncapitalize_first_letter },
          memberName: specialization.member_name,
          membersName: specialization.member_name.pluralize
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
    end
  }
end
