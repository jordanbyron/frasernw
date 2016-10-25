module PaperTrailable
  extend ActiveSupport::Concern

  DEFAULT_IGNORED_ATTRIBUTES = [:saved_token, :review_object, :review_item, :token]

  # If we can't find the appropriate version, default back to the model itself
  def creation
    versions.where(event: "create").first || OpenStruct.new(
      created_at: created_at,
      safe_user: UnknownUser.new,
      next: nil,
      secret_editor: ""
    )
  end

  def creator
    creation.safe_user
  end

  def post_creation_version
    if created_at == updated_at
      self
    else
      creation.next
    end
  end

  def last_update
    masked_update_versions.last || creation
  end

  def masked_update_versions
    versions.where(event: "update").reject{|version| version.completely_masked?}
  end

  def last_update_changeset
    last_update.masked_changeset
  end

  def last_updated_at
    last_update.created_at
  end

  def last_update_editor
    last_update.secret_editor
  end

  def last_updater
    last_update.safe_user
  end

  def paper_trail_ignored_attributes
    self.class.paper_trail_ignored_attributes
  end

  def change_date(&block)
    versions.order(:created_at).find_last do |version|
      !version.reify.present? || !block.call(version.reify)
    end.try(:created_at).try(:to_date)
  end

  module ClassMethods
    def paper_trail_ignored_attributes
      if defined?(self::PAPER_TRAIL_IGNORED_ATTRIBUTES)
        self::PAPER_TRAIL_IGNORED_ATTRIBUTES
      else
        DEFAULT_IGNORED_ATTRIBUTES
      end
    end
  end

  included do
    has_paper_trail ignore: paper_trail_ignored_attributes,
      class_name: "Version"
  end
end
