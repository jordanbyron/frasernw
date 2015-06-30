module GenerateHistory
  # prior to last
  module PriorUpdates
    def self.generator_for(model_class)
      if target.class < PaperTrailable
        FromPaperTrail
      else
        nil
      end
    end

    class FromPaperTrail < Base
      def exec
        prior_update_versions.each {|version| update_event(version) }
      end

      def prior_update_versions
        target.versions.where(event: "updated").clip(1)
      end

      def update_event(version)
        HistoryNode.new(
          target: target,
          user: User.safe_find(version.whodunnit),
          datetime: version.created_at,
          verb: :updated
        )
      end
    end
  end
end
