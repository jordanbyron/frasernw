class DataTablesController < ApplicationController
  skip_authorization_check

  # temporary endpoint to build our datatable module
  def index
    @init_data = GenerateSpecializationPage.exec(
      specialization_id: 55,
      current_user: current_user
    )

    render layout: false
  end
end
