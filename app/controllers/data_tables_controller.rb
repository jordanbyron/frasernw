class DataTablesController < ApplicationController
  def global_data
    authorize! :get, :global_data

    json = Oj.dump({
      specialists: Denormalized.fetch(:specialists),
      clinics: Denormalized.fetch(:clinics)
    })

    render text: json, content_type: "application/json"
  end
end
