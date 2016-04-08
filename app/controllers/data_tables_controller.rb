class DataTablesController < ApplicationController
  def global_data
    authorize! :get, :global_data

    json = Oj.dump({
      specialists: Serialized.fetch(:specialists),
      clinics: Serialized.fetch(:clinics)
    })

    render text: json, content_type: :json
  end
end
