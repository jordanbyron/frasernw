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
        procedureSpecializationIds: specialist.procedure_specializations.map(&:id)
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
        procedureSpecializationIds: clinic.procedure_specializations.map(&:id)
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

    # specialists and clinics have the same config for alot of things
    referent_common_config = {
      tableHeadings: [
        { label: "Name", key: "NAME" },
        { label: "Accepting New Referrals?", key: "REFERRALS" },
        { label: "Average Non-urgent Patient Waittime", key: "WAITTIME" },
        { label: "City", key: "CITY" }
      ],
      rowGenerator: "referents",
      filterFunction: "referents",
      sortFunction: "referents",
      filterComponents: ["city", "procedureSpecializations"],
      filterValues: {
        procedureSpecializations: procedure_specialization_filters,
        city: city_filters
      },
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
          procedureSpecializations: procedure_specialization_labels,
          city: city_index
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
          }.merge(referent_common_config)
        },
        clinics: {
          contentClass: "DataTable",
          props: {
            records: clinics,
            labels: {
              filterSection: "Filter Clinics"
            },
          }.merge(referent_common_config)
        }
      },
    }

    render layout: false
  end
end
