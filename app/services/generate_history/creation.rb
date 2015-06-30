module GenerateHistory
  class Creation < Base
    def self.exec(target)
      new(target).exec
    end

    def exec
      HistoryNode.new(
        target: target,
        user: target.creator,
        datetime: target.created_at,
        verb: :created
      )
    end
  end
end
