class GenerateHistory
  # prior to last
  class PriorUpdates < Base
    def exec
      return [] unless target.is_a? PaperTrailable

      prior_update_versions.map {|version| node(version) }
    end

    def prior_update_versions
      target.versions.where(event: "updated").clip(1)
    end

    def node(version)
      HistoryNode.new(
        target: target,
        user: User.safe_find(version.whodunnit),
        datetime: version.created_at,
        verb: :updated
      )
    end
  end
end
