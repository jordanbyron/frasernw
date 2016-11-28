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
          includes(:sc_category, :division, :divisions_borrowing, :specializations).
          includes(:procedures).
          inject({}) do |memo, item|
            memo.merge(item.id => {
              availableToDivisionIds: item.available_to_divisions.map(&:id),
              specializationIds: item.specializations.map(&:id),
              title: item.title,
              categoryId: item.sc_category.id,
              procedureIds: item.
                procedures.
                map(&:id),
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
              isSharedCare: item.shared_care?,
              typeMask: item.type_mask,
              collectionName: "contentItems",
              searchable: item.searchable
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
            referralIconKey: specialist.referral_icon_key,
            consultationWaitTimeKey: (
              if specialist.show_waittimes?
                specialist.consultation_wait_time_key
              else
                nil
              end
            ),
            cityIds: specialist.cities.map(&:id),
            collectionName: "specialists",
            procedureIds: specialist.procedures.map(&:id),
            bookingWaitTimeKey: specialist.booking_wait_time_key,
            acceptsReferralsViaPhone: specialist.referral_phone,
            patientsCanCall: specialist.patient_can_book?,
            sex: specialist.sex.downcase,
            scheduledDayIds: specialist.day_ids,
            languageIds: specialist.languages.map(&:id),
            hospitalIds: specialist.hospitals.map(&:id),
            clinicIds: specialist.clinics.map(&:id),
            specializationIds: specialist.specializations.map(&:id),
            procedureSpecificBookingWaitTimes: Denormalized.procedure_specific_wait_times(
              specialist,
              :booking_wait_time_key
            ),
            procedureSpecificConsultationWaitTimes: Denormalized.procedure_specific_wait_times(
              specialist,
              :consultation_wait_time_key
            ),
            isGp: specialist.is_gp,
            suffix: specialist.suffix,
            isInternalMedicine: specialist.is_internal_medicine?,
            seesOnlyChildren: specialist.sees_only_children?,
            isNew: specialist.new?,
            createdAt: specialist.created_at.to_date.to_s,
            updatedAt: specialist.updated_at.to_date.to_s,
            hospitalsWithOfficesInIds: specialist.hospitals_with_offices_in.map(&:id),
            billingNumber: specialist.padded_billing_number,
            teleserviceFeeTypes: (
              if specialist.teleservices_require_review?
                []
              else
                specialist.
                  teleservices.
                  select(&:offered?).
                  map(&:service_type_key)
              end
            ),
            interest: Denormalized.
              sanitize(specialist.interest).
              try(:convert_newlines_to_br),
            notPerformed: Denormalized.
              sanitize(specialist.not_performed).
              try(:convert_newlines_to_br),
            isPracticing: specialist.practicing?,
            hidden: specialist.hidden?,
            completedSurvey: specialist.completed_survey?
          })
        end
      end
    end,
    clinics: Module.new do
      def self.call
        Clinic.
          includes([:procedures, :specializations, :languages, :teleservices]).
          includes(:healthcare_providers).
          includes(procedure_links: :procedure).
          includes_location_data.
          includes_location_schedules.
          inject({}) do |memo, clinic|
          memo.merge(clinic.id => {
            id: clinic.id,
            name: clinic.name,
            referralIconKey: clinic.referral_icon_key,
            consultationWaitTimeKey: (
              if clinic.show_waittimes?
                clinic.consultation_wait_time_key
              else
                nil
              end
            ),
            cityIds: clinic.cities.map(&:id),
            collectionName: "clinics",
            procedureIds: clinic.procedures.map(&:id),
            bookingWaitTimeKey: clinic.booking_wait_time_key,
            acceptsReferralsViaPhone: clinic.referral_phone,
            patientsCanBook: clinic.patient_can_book?,
            scheduledDayIds: clinic.scheduled_day_ids,
            languageIds: clinic.languages.map(&:id),
            specializationIds: clinic.specializations.map(&:id),
            wheelchairAccessible: clinic.wheelchair_accessible?,
            procedureSpecificBookingWaitTimes: Denormalized.procedure_specific_wait_times(
              clinic,
              :booking_wait_time_key
            ),
            procedureSpecificConsultationWaitTimes: Denormalized.procedure_specific_wait_times(
              clinic,
              :consultation_wait_time_key
            ),
            isPrivate: clinic.private?,
            isPublic: clinic.public?,
            careProviderIds: clinic.healthcare_providers.map(&:id),
            isNew: clinic.new?,
            createdAt: clinic.created_at.to_date.to_s,
            updatedAt: clinic.updated_at.to_date.to_s,
            hospitalsInIds: clinic.hospitals_in.map(&:id),
            teleserviceFeeTypes: (
              if clinic.teleservices_require_review?
                []
              else
                clinic.
                  teleservices.
                  select(&:offered?).
                  map(&:service_type_key)
              end
            ),
            interest: Denormalized.
              sanitize(clinic.interest).
              try(:convert_newlines_to_br),
            notPerformed: Denormalized.
              sanitize(clinic.not_performed).
              try(:convert_newlines_to_br),
            hidden: clinic.hidden?,
            isOpen: clinic.open?
          })
        end
      end
    end,
    content_categories: Module.new do
      def self.call
        ScCategory.all.inject({}) do |memo, category|
          memo.merge(category.id => {
            id: category.id,
            name: category.name,
            fullName: category.full_name,
            indexDisplayFormat: category.index_display_format,
            inGlobalNavigation: category.in_global_navigation?,
            filterable: category.filterable?,
            subtreeIds: category.subtree.map(&:id),
            ancestry: category.ancestry.try(:to_i),
            componentType: component_type(category),
            collectionName: "contentCategories",
            searchable: category.searchable?
          })
        end
      end

      def self.component_type(category)
        (category.index_display_format == 0 ? "FilterTable" : "InlineArticles")
      end
    end,
    specializations: Proc.new do
      Specialization.
        includes(:specialization_options, {procedure_specializations: :procedure}).
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
            nestedProcedures: Denormalized.nested_procedures(
              specialization.procedure_specializations.arrange
            ),
            collectionName: "specializations",
            maskFiltersByReferralArea: specialization.mask_filters_by_referral_area,
            suffix: specialization.suffix,
            newInDivisionIds: specialization.
              specialization_options.
              where(is_new: true).
              map(&:division).
              map(&:id),
            hiddenInDivisionIds: specialization.
              hidden_in_divisions.
              map(&:id)
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
          id: hospital.id,
          name: hospital.name,
          address: hospital.address.try(:address),
          mapUrl: hospital.address.try(:map_url),
          phoneAndFax: hospital.phone_and_fax,
          collectionName: "hospitals"
        })
      end
    end,
    cities: Proc.new do
      City.includes(:divisions).all.inject({}) do |memo, city|
        memo.merge(city.id => {
          id: city.id,
          name: city.name,
          divisionsEncompassingIds: city.divisions.map(&:id)
        })
      end
    end,
    languages: Proc.new do
      Language.all.inject({}) do |memo, language|
        memo.merge(language.id => {
          id: language.id,
          name: language.name,
          collectionName: "languages"
        })
      end
    end,
    procedures: Proc.new do
      Procedure.includes(:procedure_specializations).
        inject({}) do |memo, procedure|

        memo.merge(procedure.id => {
          id: procedure.id,
          nameRelativeToParents: procedure.try(:name_relative_to_parents),
          name: procedure.name,
          specializationIds: procedure.procedure_specializations.map(&:specialization_id),
          waitTimesSpecified: {
            specialists: procedure.specialists_specify_wait_times,
            clinics: procedure.clinics_specify_wait_times
          },
          assumedSpecializationIds: {
            specialists: procedure.
              procedure_specializations.
              select{|ps| ps.assumed_for?(:specialists)}.
              map(&:specialization).
              map(&:id),
            clinics: procedure.
              procedure_specializations.
              select{|ps| ps.assumed_for?(:clinics)}.
              map(&:specialization).
              map(&:id)
          },
          childrenProcedureIds: procedure.children.map(&:id),
          fullName: procedure.full_name,
          ancestorIds: procedure.ancestor_ids,
          collectionName: "procedures"
        })
      end
    end,
    divisions: Module.new do
      def self.call
        Division.all.inject({}) do |memo, division|
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
            openToSpecializationPanel: division.
              specialization_options.
              inject({}) do |memo, specialization_option|
                memo.merge(specialization_option.specialization_id => {
                  type: specialization_option.open_to_type.to_s.camelize(:lower),
                  id: specialization_option.open_to_id
                })
              end,
            showingSpecializationIds: division.showing_specializations.map(&:id)
          })
        end
      end
    end,
    referral_forms: Proc.new do
      [ Clinic, Specialist ].inject({}) do |memo, klass|
        memo.merge(klass.all.includes(:referral_forms).inject({}) do |memo, profile|
          memo.merge(profile.referral_forms.inject({}) do |memo, form|
            memo.merge(form.id => {
              id: form.id,
              filename: form.form_file_name,
              referrableType: form.referrable_type,
              referrableId: form.referrable_id,
              label:  "#{profile.name} - #{form.form_file_name}"
            })
          end)
        end)
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
          endDate: item.end_date,
          collectionName: "newsItems"
        })
      end
    end,
    issues: Proc.new do
      Issue.includes(:assignees, :versions).inject({}) do |memo, issue|
        memo.merge(issue.id => issue.to_hash)
      end
    end,
    change_requests: Proc.new do
      Issue.change_request.includes(:assignees, :versions).inject({}) do |memo, issue|
        memo.merge(issue.id => issue.to_hash)
      end
    end
  }

  def self.procedure_specific_wait_times(linked_item, waittime_type)
    linked_item.procedure_links.inject({}) do |memo, procedure_link|
      if procedure_link.specifies_wait_times? && procedure_link.send(waittime_type)
        memo.merge(procedure_link.procedure_id => procedure_link.send(waittime_type))
      else
        memo
      end
    end
  end

  def self.nested_procedures(nested_procedure_specializations)
    nested_procedure_specializations.inject({}) do |memo, (ps, children)|
      memo.merge({
        ps.procedure_id => {
          id: ps.procedure_id,
          focused: {
            clinics: ps.focused_for?(:clinics),
            specialists: ps.focused_for?(:specialists)
          },
          assumed: {
            clinics: ps.assumed_for?(:clinics),
            specialists: ps.assumed_for?(:specialists)
          },
          children: nested_procedures(children)
        }
      })
    end
  end

  def self.sanitize(input)
    ActionController::Base.helpers.sanitize(input)
  end
end
