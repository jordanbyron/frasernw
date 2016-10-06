class DataTablesController < ApplicationController
  def global_data
    authorize! :get, :global_data

    # json = Oj.dump({
    #   specialists: Denormalized.fetch(:specialists),
    #   clinics: Denormalized.fetch(:clinics),
    #   procedures: Denormalized.fetch(:procedures),
    #   hospitals: Denormalized.fetch(:hospitals),
    #   contentCategories: Denormalized.fetch(:content_categories),
    #   languages: Denormalized.fetch(:languages),
    #   cities: Denormalized.fetch(:cities),
    #   specializations: Denormalized.fetch(:specializations),
    #   contentItems: Denormalized.fetch(:content_items),
    #   divisions: Denormalized.fetch(:divisions),
    #   referralIcons: Referrable::REFERRAL_ICONS,
    #   referralTooltips: Referrable::REFERRAL_TOOLTIPS
    # })

    render text: {}, content_type: "application/json"
  end
end
