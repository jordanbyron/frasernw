# use this module to add paper trail to a model

module PaperTrailable
  extend ActiveSupport::Concern

  # If we can't find the appropriate version, default back to the model itself
  def creation
    versions.where(event: "create").first || OpenStruct.new(
      safe_user: UnknownUser.new,
    )
  end

  def creator
    creation.safe_user
  end

  # Once again, have fallbacks just in case there isn't an updated version
  def last_update
    versions.where(event: "update").last || OpenStruct.new(
      created_at: updated_at,
      safe_user: UnknownUser.new
    )
  end

  def last_updated_at
    last_update.created_at
  end

  def last_updater
    last_update.safe_user
  end

  included do
    has_paper_trail ignore: [:saved_token, :review_object, :review_item]
  end
end
