class GenerateHistory
  # prior to last
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
end
