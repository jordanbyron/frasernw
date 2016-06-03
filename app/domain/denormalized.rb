module Denormalized
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

  def self.prepare_markdown_content(markdown_content)
    html = BlueCloth.
      new(markdown_content).
      to_html

    html.safe_for_javascript!

    html
  end

  GENERATORS = {
    content_items: Module.new do
      def self.call
        ScItem.
          includes(:sc_category, :division, :divisions_sharing, :specializations).
          inject({}) do |memo, item|
            memo.merge(item.id => {
              availableToDivisionIds: item.available_to_divisions.map(&:id),
              specializationIds: item.specializations.map(&:id),
              title: item.title,
              categoryId: item.sc_category.id,
              categoryIds: [item.sc_category, item.sc_category.ancestors].
                flatten.
                map(&:id),
              procedureIds: item.
                procedure_specializations.
                map(&:subtree).
                flatten.
                uniq.
                map(&:procedure_id),
              content: (
                if item.markdown_content.present?
                  Denormalized.prepare_markdown_content(item.markdown_content)
                else
                  ""
                end
              ),
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
        Specialist.includes_specialization_page.inject({}) do |memo, specialist|
          memo.merge(specialist.id => {
            id: specialist.id,
            name: specialist.name,
            firstName: specialist.firstname,
            lastName: specialist.lastname,
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
            customLagtimes: custom_procedure_times(specialist, :lagtime_mask),
            customWaittimes: custom_procedure_times(specialist, :waittime_mask),
            isGp: specialist.is_gp,
            isInternalMedicine: specialist.is_internal_medicine?,
            seesOnlyChildren: specialist.sees_only_children?,
            isNew: specialist.new?,
            isInProgress: specialist.in_progress,
            createdAt: specialist.created_at.to_date.to_s,
            updatedAt: specialist.updated_at.to_date.to_s,
            showInTable: specialist.show_in_table?,
            teleserviceFeeTypes: specialist.
              teleservices.
              select(&:offered?).
              map(&:service_type)
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

      def self.custom_procedure_times(specialist, method)
        specialist.capacities.inject({}) do |memo, capacity|
          if capacity.send(method)
            memo.merge(capacity.procedure.id => capacity.send(method))
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
          includes(:healthcare_providers).
          includes_location_data.
          includes_location_schedules.
          inject({}) do |memo, clinic|
          memo.merge(clinic.id => {
            id: clinic.id,
            name: clinic.name,
            statusClassKey: clinic.status_class_hash,
            statusMask: (clinic.status_mask || 0),
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
            customLagtimes: self.custom_procedure_times(clinic, :lagtime_mask),
            customWaittimes: self.custom_procedure_times(clinic, :waittime_mask),
            isPrivate: clinic.private?,
            isPublic: clinic.public?,
            careProviderIds: clinic.healthcare_providers.map(&:id),
            isNew: clinic.new?,
            isInProgress: clinic.in_progress,
            createdAt: clinic.created_at.to_date.to_s,
            updatedAt: clinic.updated_at.to_date.to_s,
            showInTable: clinic.show_in_table?,
            teleserviceFeeTypes: clinic.
              teleservices.
              select(&:offered?).
              map(&:service_type)
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

      def self.custom_procedure_times(clinic, method)
        clinic.focuses.inject({}) do |memo, focus|
          if focus.send(method)
            memo.merge(focus.procedure.id => focus.send(method))
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
      Specialization.
        includes(:specialization_options).
        inject({}) do |memo, specialization|
          memo.merge(specialization.id => {
            id: specialization.id,
            name: specialization.name,
            assumedList: specialization.procedure_specializations.assumed_specialist.
              reject{ |ps| ps.parent.present? }.
              sort{ |a,b| a.procedure.name <=> b.procedure.name }.
              map{ |ps| ps.procedure.name.uncapitalize_first_letter },
            memberName: specialization.member_name,
            membersName: specialization.member_name.pluralize,
            nestedProcedureIds: Denormalized.transform_nested_procedure_specializations(
              specialization.procedure_specializations.includes(:procedure).arrange
            ),
            maskFiltersByReferralArea: specialization.mask_filters_by_referral_area,
            suffix: specialization.suffix
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
      Procedure.includes(:procedure_specializations).
        inject({}) do |memo, procedure|

        memo.merge(procedure.id => {
          nameRelativeToParents: procedure.try(:name_relative_to_parents),
          name: procedure.name,
          specializationIds: procedure.procedure_specializations.map(&:specialization_id),
          customWaittime: {
            specialists: procedure.specialist_wait_time,
            clinics: procedure.clinic_wait_time
          },
          assumedSpecializationIds: {
            specialists: procedure.
              procedure_specializations.
              select(&:assumed_specialist?).
              map(&:specialization).
              map(&:id),
            clinics: procedure.
              procedure_specializations.
              select(&:assumed_clinic?).
              map(&:specialization).
              map(&:id)
          },
          childrenProcedureIds: procedure.children.map(&:id)
        })
      end
    end,
    divisions: Module.new do
      def self.call
        Division.standard.inject({}) do |memo, division|
          memo.merge(division.id => {
            id: division.id,
            name: division.name,
            referralCities: Specialization.all.inject({}) do |memo, specialization|
              memo.merge(specialization.id => division.
                local_referral_cities(specialization).
                reject(&:hidden).
                map(&:id)
              )
            end,
            openToSpecializationPanel: Specialization.
              all.
              inject({}) do |memo, specialization|
                memo.merge(specialization.id => self.open_to_panel(
                  specialization,
                  division
                ) )
              end
          })
        end
      end

      def self.open_to_panel(specialization, division)
        specialization_option = specialization.
          specialization_options.
          to_a.
          find do |option|
            option.division_id == division.id
          end

        if specialization_option.open_to_sc_category?
          {
            type: "contentCategories",
            id: specialization_option.open_to
          }
        else
          {
            type: specialization_option.open_to
          }
        end
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
      Clinic::LAGTIME_LABELS.inject({}) do |memo, (key, value)|
        memo.merge(key.to_i => value)
      end.merge(0 => "Any timeframe")
    end,
    respondsWithinSummaryLabels: Proc.new do
      Clinic::LAGTIME_LABELS.inject({}) do |memo, (key, value)|
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
    end,
    news_items: Proc.new do
      NewsItem.includes(:divisions).inject({}) do |memo, item|
        memo.merge(item.id => {
          id: item.id,
          title: item.label,
          type: item.type,
          ownerDivisionId: item.owner_division_id,
          divisionDisplayIds: item.divisions.map(&:id),
          isCurrent: item.current?,
          startDate: item.start_date,
          endDate: item.end_date
        })
      end
    end
  }

  def self.transform_nested_procedure_specializations(procedure_specializations)
    procedure_specializations.inject({}) do |memo, (ps, children)|
      memo.merge( { ps.procedure.id => {
        focused: ps.focused?,
        assumed: {
          clinics: ps.assumed_clinic?,
          specialists: ps.assumed_specialist?
        },
        customWaittime: {
          specialists: ps.specialist_wait_time,
          clinics: ps.clinic_wait_time
        },
        children: transform_nested_procedure_specializations(children)
      } } )
    end
  end
end
