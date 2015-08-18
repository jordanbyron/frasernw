class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    @select_options = [
      { key: "tricycle", label: "Trike"},
      { key: "bicycle", label: "Bike"},
      { key: "car", label: "Car"}
    ]
    @table_headings = [ "product_id", "product", "date", "link" ]
    @records = [
      {
        id: 1,
        name: "tricycle",
        date: "05/05/2015",
        link: "www.google.ca"
      },
      {
        id: 2,
        name: "bicycle",
        date: "05/06/2015",
        link: "www.wikipedia.org"
      },
      {
        id: 3,
        name: "car",
        date: "05/07_2015",
        link: "www.amazon.ca"
      }
    ]

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
