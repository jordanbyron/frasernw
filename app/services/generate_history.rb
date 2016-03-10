class GenerateHistory < ServiceObject

  # one subgenerator for each kind of lifecycle event
  # events should be mutually exclusive!
  # i.e. before I had 'archived' here, but that duplicates the 'update' events

  attribute :target
  attribute :event_types, Array

  def call
    return [] unless target.id.present?

    unsorted.sort_by {|node| node.datetime }
  end

  def generators
    event_types.any? ? event_types : GenerateHistory::Base.descendants
  end

  def unsorted
    generators.inject([]) do |memo, generator|
      memo + generator.call(target: target)
    end
  end

  class Base < ServiceObject
    attribute :target
  end

  class Creation < Base
    def call
      [
        HistoryNode.new(
          target: target,
          user: target.creator,
          datetime: target.created_at,
          verb: :created,
          new_version: target.post_creation_version,
          note: target.is_a?(FeedbackItem) ? target.feedback : nil
        )
      ]
    end
  end

  class Annotations < Base
    def call
      return [] unless target.is_a? Noteable

      from_notes_records + from_admin_notes_field
    end

    def from_notes_records
      target.persisted_notes.map {|note| node(note) }
    end

    def node(note)
      HistoryNode.new(
        target: target,
        user: (note.user || UnknownUser.new),
        datetime: note.created_at,
        verb: :annotated,
        note: note.content
      )
    end

    def from_admin_notes_field
      if !target.respond_to?(:admin_notes) || !target.admin_notes.present?
        return []
      else
        [
          HistoryNode.new(
            target: target,
            user: migrating_user,
            datetime: DateTime.new(2015, 7, 13),
            verb: :migrated_annotation,
            note: target.admin_notes.gsub("\n", "(newline) ")
          )
        ]
      end
    end

    # Brian Gracie
    def migrating_user
      @migrating_user ||= User.find(3243)
    end
  end

  class LastUpdated < Base
    def call
      return [] if target.created_at.to_i == target.last_updated_at.to_i

      [
        HistoryNode.new(
          target: target,
          user: target.last_updater,
          datetime: target.last_updated_at,
          verb: :last_updated,
          secret_editor: target.last_update_editor,
          new_version: target,
          changeset: target.last_update_changeset
        )
      ]
    end
  end

  class PriorUpdates < Base
    def call
      return [] unless target.is_a? PaperTrailable

      prior_update_versions.map {|version| node(version) }
    end

    def prior_update_versions
      target.
        masked_update_versions.
        clip(1)
    end

    def node(version)
      HistoryNode.new(
        target: target,
        user: version.safe_user,
        datetime: version.created_at,
        secret_editor: version.secret_editor,
        verb: :updated,
        new_version: version.next,
        changeset: version.masked_changeset
      )
    end
  end

  module ChildEvents
    class ReviewItem < GenerateHistory::Base
      def call
        return [] unless target.is_a? Reviewable

        target.review_items.inject([]) do |memo, review_item|
          memo + review_item.history
        end
      end
    end

    class FeedbackItem < GenerateHistory::Base
      def call
        return [] unless target.is_a? Feedbackable

        target.feedback_items.inject([]) do |memo, feedback_item|
          memo + feedback_item.history
        end
      end
    end

    class ReferralForm < GenerateHistory::Base
      def call
        return [] unless target.is_a? Referrable

        target.referral_forms.inject([]) do |memo, referral_form|
          memo + referral_form.history
        end
      end
    end

    class SecretToken < GenerateHistory::Base
      def call
        return [] unless target.is_a? TokenAccessible

        target.secret_tokens.inject([]) do |memo, secret_token|
          memo + secret_token.history
        end
      end
    end

    class UserControls < GenerateHistory::Base
      def call
        if target.respond_to?(:user_controls)
          target.user_controls.inject([]) do |memo, control|
            if !control.last_visited.nil?
              memo << HistoryNode.new(
                user: control.user,
                datetime: control.last_visited,
                verb: :last_visited,
                target: target
              )
            else
              memo
            end
          end
        else
          []
        end
      end
    end
  end
end
