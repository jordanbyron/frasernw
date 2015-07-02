class GenerateHistory
  # prior to last
  class PriorUpdates < Base
    def exec
      return [] unless target.is_a? PaperTrailable

      prior_update_versions.map {|version| node(version) }
    end

    def prior_update_versions
      target.versions.where(event: "update").clip(1)
    end

    def node(version)
      HistoryNode.new(
        target: target,
        user: version.safe_user,
        datetime: version.created_at,
        verb: :updated
      )
    end
  end
end
