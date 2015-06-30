module GenerateHistory
  class LastUpdated
    def self.exec(target)
      new(target).exec
    end

    def exec
      HistoryNode.new(
        target: target,
        user: target.last_updater,
        datetime: target.last_updated_at,
        verb: :created
      )
    end
  end
end
