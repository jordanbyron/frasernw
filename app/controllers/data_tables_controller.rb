class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    @table_headings = [ "product_id", "product", "date", "link" ]
    @table_rows = [
      [ 1, "tricycle", "05/05/2015", "www.google.ca" ],
      [ 2, "bicycle", "05/06/2015", "www.wikipedia.org" ],
      [ 3, "car", "05/07_2015", "www.amazon.ca" ]
    ]

    render layout: false
  end
end
