class DataTablesController < ApplicationController
  def global_data
    authorize! :get, :global_data

    render(json: {
      specialists: Serialized.fetch(:specialists),
      clinics: Serialized.fetch(:clinics)
    })
  end
end
