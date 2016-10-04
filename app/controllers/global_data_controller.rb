class GlobalDataController < ApplicationController
  def show
    authorize! :get, :global_data

    json = Oj.dump({
      specialists: Denormalized.fetch(:specialists),
      clinics: Denormalized.fetch(:clinics),
      procedures: Denormalized.fetch(:procedures),
      hospitals: Denormalized.fetch(:hospitals),
      contentCategories: Denormalized.fetch(:content_categories),
      languages: Denormalized.fetch(:languages),
      cities: Denormalized.fetch(:cities),
      specializations: Denormalized.fetch(:specializations),
      contentItems: Denormalized.fetch(:content_items),
      divisions: Denormalized.fetch(:divisions),
      referentStatusIcons: Specialist::STATUS_CLASS_HASH.invert
    })


    response.headers["Content-Type"] = "application/json"
    response.headers["Cache-Control"] = "public, max-age=86400"

    render text: json
  end
end
