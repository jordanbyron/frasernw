class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    @table_rows = [
      [ "this", "is", "the", "first", "row" ],
      [ "this", "is", "the", "second", "row" ],
      [ "this", "is", "the", "third", "row" ]
    ]

    render layout: false
  end
end
