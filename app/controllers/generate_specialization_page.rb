class GenerateSpecializationPage
  include ServiceObject.exec_with_args(:specialization_id)

  def exec
    @init_data = {
      selectedPanel: "specialists",
      panelNav: panel_nav,
      globalData: global_data,
      panels: {
        specialists: specialists_panel,
        clinics: clinics_panel
      }
    }
  end

  private

  def panel_nav
    [
      {
        key: "specialists",
        label: "Specialists"
      },
      {
        key: "clinics",
        label: "Clinics"
      }
    ]
  end

  def lagtimes
    Clinic::LAGTIME_HASH.map do |key, value|
      { key: key, label: value }
    end.sort_by{ |elem| elem[:key] }
  end

  def procedure_specialization_filters
    specialization.
      procedure_specializations.
      focused.
      inject({}) do |memo, ps|
        memo.merge(ps.id => false)
      end
  end

  def procedure_specialization_labels
    transform_procedure_specializations = Proc.new do |hash|
      hash.map do |key, value|
        {
          key: key.id,
          label: key.procedure.name,
          children: transform_procedure_specializations.call(value)
        }
      end.sort_by{ |elem| elem[:label] }
    end

    transform_procedure_specializations.call(
      specialization.arranged_procedure_specializations(:focused)
    )
  end

  def city_filters
    City.all.inject({}) do |memo, city|
      memo.merge(city.id => true)
    end
  end

  def city_index
    City.all.inject({}) do |memo, city|
      memo.merge(city.id => city.name)
    end
  end

  def clinics
    specialization.
      clinics.
      includes(clinic_locations: {:schedule => [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday]}).
      map do |clinic|
      {
        id: clinic.id,
        name: clinic.name,
        statusIconClasses: clinic.status_class,
        waittime: clinic.waittime,
        cityIds: clinic.cities.map(&:id),
        collectionName: "clinics",
        procedureSpecializationIds: clinic.procedure_specializations.map(&:id),
        respondsWithin: clinic.lagtime_mask,
        acceptsReferralsViaPhone: clinic.referral_phone,
        patientsCanBook: clinic.patient_can_book?,
        scheduledDayIds: clinic.day_ids
      }
    end
  end

  def specialists
    specialization.specialists.map do |specialist|
      {
        id: specialist.id,
        name: specialist.name,
        statusIconClasses: specialist.status_class,
        waittime: specialist.waittime,
        cityIds: specialist.cities.map(&:id),
        collectionName: "specialists",
        procedureSpecializationIds: specialist.procedure_specializations.map(&:id),
        respondsWithin: specialist.lagtime_mask,
        acceptsReferralsViaPhone: specialist.referral_phone,
        patientsCanBook: specialist.patient_can_book?,
        sex: specialist.sex.downcase,
        scheduledDayIds: specialist.day_ids
      }
    end
  end

  def specialization
    @specialization ||= Specialization.find(specialization_id)
  end

  def referent_common_filter_values
    {
      procedureSpecializations: procedure_specialization_filters,
      city: city_filters,
      referrals: {
        acceptsReferralsViaPhone: false,
        respondsWithin: 0,
        patientsCanBook: false
      },
      sex: {
        male: false,
        female: false
      }
    }
  end

  def global_data
    {
      labels: {
        city: city_index,
        procedureSpecializations: procedure_specialization_labels,
        referrals: {
          acceptsReferralsViaPhone: "Accepts referrals Via phone",
          patientsCanBook: "Patients can call to book after referral",
          respondsWithin: {
            self: "Responded to within",
            values: [{key: 0, label: "Any timeframe"}] + lagtimes
          },
        },
        sex: [
          { key: :male, label: "Male"},
          { key: :female, label: "Female"}
        ],
        schedule: Schedule::DAY_HASH
      }
    }
  end

  def referent_common_config
    {
      tableHeadings: [
        { label: "Name", key: "NAME" },
        { label: "Accepting New Referrals?", key: "REFERRALS" },
        { label: "Average Non-urgent Patient Waittime", key: "WAITTIME" },
        { label: "City", key: "CITY" }
      ],
      rowGenerator: "referents",
      sortFunction: "referents",
      sortConfig: {
        column: "NAME",
        order: "ASC"
      },
      filterVisibility: {
        city: false,
      }
    }
  end

  def specialists_panel
    {
      contentClass: "DataTable",
      props: {
        records: specialists,
        labels: {
          filterSection: "Filter Specialists"
        },
        filterFunction: "specialists",
        filterValues: referent_common_filter_values.merge({
          schedule: {
            6 => false,
            7 => false
          }
        }),
        filterArrangements: {
          schedule: [6, 7]
        },
        filterComponents: ["procedureSpecializations", "referrals", "sex", "schedule", "city"]
      }.merge(referent_common_config)
    }
  end

  def clinics_panel
    {
      contentClass: "DataTable",
      props: {
        records: clinics,
        labels: {
          filterSection: "Filter Clinics"
        },
        filterValues: referent_common_filter_values.merge({
          schedule: Schedule::DAY_HASH.keys.inject({}) do |memo, day|
            memo.merge(day => false)
          end
        }),
        filterArrangements: {
          schedule: Schedule::DAY_HASH.keys
        },
        filterFunction: "clinics",
        filterComponents: ["procedureSpecializations", "referrals", "schedule", "city"]
      }.merge(referent_common_config)
    }
  end
end
