class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    @table_headings = [ "Name", "Accepting New Referrals?", "Average Non-urgent Patient Waittime", "City" ]
    @records =
      Specialization.find(4).specialists.map do |specialist|
        {
          id: specialist.id,
          name: specialist.name,
          status_icon_classes: specialist.status_class,
          waittime: specialist.waittime,
          cities: specialist.cities.map(&:name).join(" and ")
        }
      end

    @filters = {
      id: {
        1 => true,
        2 => true,
        3 => false
      }
    }

    render layout: false
  end
end
