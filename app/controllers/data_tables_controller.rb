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
        cities: specialist.cities.map(&:name).join(" and ")
      }
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
        id: true,
      },
      filters: {
        id: {
          1 => true,
          2 => true,
          3 => false
        }
      }
    }

    render layout: false
  end
end
