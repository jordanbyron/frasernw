class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    specialists = Specialization.find(4).specialists.map do |specialist|
      {
        id: specialist.id,
        name: specialist.name,
        statusIconClasses: specialist.status_class,
        waittime: specialist.waittime,
        cityIds: specialist.cities.map(&:id),
        collectionName: "specialists"
      }
    end

    clinics = Specialization.find(4).clinics.map do |clinic|
      {
        id: clinic.id,
        name: clinic.name,
        statusIconClasses: clinic.status_class,
        waittime: clinic.waittime,
        cityIds: clinic.cities.map(&:id),
        collectionName: "clinics"
      }
    end

    city_index = City.all.inject({}) do |memo, city|
      memo.merge(city.id => city.name)
    end

    city_filters = City.all.inject({}) do |memo, city|
      memo.merge(city.id => true)
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
      filterComponents: ["city"],
      filterValues: {
        city: city_filters
      },
      sortConfig: {
        column: "NAME",
        order: "ASC"
      },
      filterVisibility: {
        city: true,
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
      panels: {
        specialists: {
          contentClass: "DataTable",
          props: {
            records: specialists,
            labels: {
              city: city_index,
              filterSection: "Filter Specialists"
            },
          }.merge(referent_common_config)
        },
        clinics: {
          contentClass: "DataTable",
          props: {
            records: clinics,
            labels: {
              city: city_index,
              filterSection: "Filter Clinics"
            },
          }.merge(referent_common_config)
        }
      },
    }

    render layout: false
  end
end
