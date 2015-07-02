# use this module to add paper trail to a model

module PaperTrailable
  extend ActiveSupport::Concern

  def creation
    versions.where(event: "create").first
  end

  def creator
    creation.safe_user
  end

  def last_update
    versions.where(event: "update").first
  end

  def last_updater
    last_update.safe_user
  end

  included do
    has_paper_trail ignore: [:saved_token, :review_object, :review_item]
  end
end
