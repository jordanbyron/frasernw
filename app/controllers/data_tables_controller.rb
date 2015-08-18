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
      tableHeadings: [
        "Name",
        "Accepting New Referrals?",
        "Average Non-urgent Patient Waittime",
        "City"
      ],
      records: records,
      filterVisibility: {
        city: true,
      },
      labels: {
        city: city_index
      },
      filters: {
        city: city_filters
      }
    }

    render layout: false
  end
end
