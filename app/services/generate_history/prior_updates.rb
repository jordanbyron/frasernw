class GenerateHistory
  # prior to last
  class PriorUpdates < Base
    def exec
      return [] unless target.is_a? PaperTrailable

      prior_update_versions.inject([]) do |memo, version|
        if version.null_changeset?
          memo
        else
          memo << node(version)
        end
      end
    end

    def prior_update_versions
      target.versions.where(event: "update").clip(1)
    end

    def node(version)
      HistoryNode.new(
        target: target,
        user: version.safe_user,
        datetime: version.created_at,
        verb: :updated,
        new_version: version.next,
        changeset: version.changeset
      )
    end
  end
end
