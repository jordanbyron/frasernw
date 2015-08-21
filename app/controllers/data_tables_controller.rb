class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    records = Specialization.find(4).specialists.map do |specialist|
      {
        id: specialist.id,
        name: specialist.name,
        status_icon_classes: specialist.status_class,
        waittime: specialist.waittime,
        cityIds: specialist.cities.map(&:id)
      }
    end

    city_index = City.all.inject({}) do |memo, city|
      memo.merge(city.id => city.name)
    end

    city_filters = City.all.inject({}) do |memo, city|
      memo.merge(city.id => true)
    end

    @init_data = {
      selectedPanel: "specialists",
      panelNav: [
        {
          key: "specialists",
          label: "Specialists"
        }
      ],
      panels: {
        specialists: {
          contentClass: "DataTable",
          props: {
            tableHeadings: [
              { label: "Name", key: "NAME" },
              { label: "Accepting New Referrals?", key: "REFERRALS" },
              { label: "Average Non-urgent Patient Waittime", key: "WAITTIME" },
              { label: "City", key: "CITY" }
            ],
            records: records,
            filterVisibility: {
              city: true,
            },
            labels: {
              city: city_index,
              filterSection: "Filter Specialists"
            },
            rowGenerator: "specialist",
            filterFunction: "specialist",
            sortFunction: "specialist",
            filterComponents: ["city"],
            filterValues: {
              city: city_filters
            },
            sortConfig: {
              column: "NAME",
              order: "ASC"
            }
          }
        }
      },
    }

    render layout: false
  end
end
