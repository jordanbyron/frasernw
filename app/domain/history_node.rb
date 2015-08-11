# Wraps an event that has happened to the target in order to provide a consistent interface for presentation

class HistoryNode
  include CustomPathHelper
  include Rails.application.routes.url_helpers
  include ReviewItemsHelper

  # {
  #   user: current_user,
  #   verb: :annotated,
  #   target: ReviewItem.last,
  #   datetime: DateTime.now,
  #   content: "This is a note"
  # }

  # add 'parent'?/ 'on'?

  attr_reader :raw
  delegate :datetime, :changeset, to: :raw

  def initialize(attrs)
    @raw = OpenStruct.new(attrs)
  end

  def user
    raw.user.name
  end

  def date
    raw.datetime.to_s(:date_ordinal)
  end

  def verb
    if archiving?
      "archived"
    elsif raw.verb == :migrated_annotation
      "'admin notes' field migrated"
    else
      raw.verb.to_s.gsub("_", " ")
    end
  end

  def target
    raw.target.numbered_label
  end

  def note
    "\"#{raw.note}\""
  end

  def has_note?
    raw.note.present?
  end

  def show_new_version_path?
    VersionsController::SUPPORTED_KLASSES_FOR_SHOW.include?(raw.target.class) && new_version_path.present?
  end

  def new_version_path
    duck_path(raw.new_version)
  end

  def target_is?(item)
    item == raw.target
  end

  def target_klass
    raw.target.class
  end

  def archiving?
    changeset.present? && changeset.keys[0] == "archived"
  end

  def target_link
    smart_duck_path(raw.target)
  end
end
