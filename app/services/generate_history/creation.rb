class GenerateHistory
  class Creation < Base
    def exec
      [
        HistoryNode.new(
          target: target,
          user: target.creator,
          datetime: target.created_at,
          verb: :created
        )
      ]
    end
  end
end
