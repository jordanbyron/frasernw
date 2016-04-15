# Wraps an event that has happened to the target in order to provide a consistent
# interface for presentation

class HistoryNode
  # {
  #   user: current_user,
  #   verb: :annotated,
  #   target: ReviewItem.last,
  #   datetime: DateTime.now,
  #   content: "This is a note"
  # }

  # add 'parent'?/ 'on'?

  attr_reader :raw
  delegate :datetime, :secret_editor, to: :raw

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

  def review?
    secret_editor.present?
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
    VersionsController::SUPPORTED_KLASSES_FOR_SHOW.include?(raw.target.class) &&
      new_version_path.present?
  end

  def new_version_path
    CustomPathHelper.duck_path(raw.new_version)
  end

  def target_is?(item)
    item == raw.target
  end

  def target_klass
    raw.target.class
  end

  def archiving?
    raw.changeset.present? && raw.changeset.keys[0] == "archived"
  end

  def target_link
    CustomPathHelper.smart_duck_path(raw.target)
  end

  def annotation
    if raw.target.is_a?(ReviewItem) && raw.target.no_updates?
      " (No changes)"
    else
      ""
    end
  end

  def changeset?
    raw.changeset.present?
  end

  def changeset
    Changeset.new(raw.changeset, target_klass)
  end

  class Changeset
    def initialize(raw_changeset, target_klass)
      @raw_changeset = raw_changeset
      @target_klass = target_klass
    end

    def attributes
      @attributes ||= @raw_changeset.map do |attribute, values|
        Attribute.new(attribute, values, @target_klass)
      end
    end

    class Attribute
      def initialize(attribute, values, target_klass)
        @attribute = attribute
        @values = values
        @target_klass = target_klass
      end

      def name
        @target_klass.human_attribute_name(@attribute)
      end

      def review_object?
        @attribute == "review_object"
      end

      HANDLED_VALUES = {
        "evidence_id" => Proc.new do |value|
          Evidence.safe_find(value).try(:level)
        end
      }

      def handled_value?
        HANDLED_VALUES.keys.include?(@attribute)
      end

      def handled_value(value)
        HANDLED_VALUES[@attribute].call(value)
      end

      def human_value(value)
        return handled_value(value) if handled_value?
        return 'Yes' if value == true
        return 'No' if value == false

        translation_key = [
          "#{@target_klass.i18n_scope}",
          "values",
          @target_klass.model_name.i18n_key,
          @attribute,
          value
        ].join(".")

        begin
          I18n.translate(
            translation_key,
            raise: I18n::MissingTranslationData
          )
        rescue I18n::MissingTranslationData
          value
        end
      end

      def from
        human_value(@values[0])
      end

      def to
        human_value(@values[1])
      end

      def from?
        @values[0].present?
      end

      def to?
        @values[1].present?
      end
    end
  end
end
