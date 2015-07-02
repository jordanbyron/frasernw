# use this module to add paper trail to a model

module PaperTrailable
  extend ActiveSupport::Concern

  def creator
    User.safe_find(
      versions.where(event: "create").first.whodunnit
    )
  end

  def last_update
    User.safe_find(
      versions.where(event: "update").first.whodunnit
    )
  end

  def last_updater
    User.safe_find(
      versions.where(event: "update").first.whodunnit
    )
  end

  included do
    has_paper_trail ignore: [:saved_token, :review_object, :review_item]
  end
end
