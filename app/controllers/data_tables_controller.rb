class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    specialization = Specialization.find(4)

    specialists = specialization.specialists.map do |specialist|
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
        sex: specialist.sex.downcase
      }
    end

    clinics = specialization.clinics.map do |clinic|
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
        patientsCanBook: clinic.patient_can_book?
      }
    end

    city_index = City.all.inject({}) do |memo, city|
      memo.merge(city.id => city.name)
    end

    city_filters = City.all.inject({}) do |memo, city|
      memo.merge(city.id => true)
    end

    transform_procedure_specializations = Proc.new do |hash|
      hash.map do |key, value|
        {
          key: key.id,
          label: key.procedure.name,
          children: transform_procedure_specializations.call(value)
        }
      end.sort_by{ |elem| elem[:label] }
    end
    procedure_specialization_labels = transform_procedure_specializations.call(
      specialization.arranged_procedure_specializations(:focused)
    )

    procedure_specialization_filters = specialization.
      procedure_specializations.
      focused.
      inject({}) do |memo, ps|
        memo.merge(ps.id => false)
      end

    lagtimes = Clinic::LAGTIME_HASH.map do |key, value|
      { key: key, label: value }
    end.sort_by{ |elem| elem[:key] }

    referent_common_filter_values = {
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

    # specialists and clinics have the same config for alot of things
    referent_common_config = {
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

    @init_data = {
      selectedPanel: "specialists",
      panelNav: [
        {
          key: "specialists",
          label: "Specialists"
        },
        {
          key: "clinics",
          label: "Clinics"
        }
      ],
      globalData: {
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
          ]
        }
      },
      panels: {
        specialists: {
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
            filterComponents: ["procedureSpecializations", "referrals", "sex", "city"]
          }.merge(referent_common_config)
        },
        clinics: {
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
            filterComponents: ["procedureSpecializations", "referrals", "city"]
          }.merge(referent_common_config)
        }
      },
    }

    render layout: false
  end
end
