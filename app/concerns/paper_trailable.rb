# use this module to add paper trail to a model

module PaperTrailable
  extends ActiveSupport::Concern

  def creator
    User.safe_find(
      versions.where(event: "create").first.whodunnit
    )
  end

  def last_update
    User.safe_find(
      versions.where(event: "last").first.whodunnit
    )
  end

  def last_updater
    User.safe_find(
      versions.where(event: "last").first.whodunnit
    )
  end

  included do
    include PaperTrailable, ignore: [:saved_token, :review_object, :review_item]
  end
end
