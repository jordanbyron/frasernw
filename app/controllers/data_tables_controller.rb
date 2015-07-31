class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    render layout: false
  end
end
