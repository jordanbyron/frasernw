module GenerateHistory
  module AnonymousCreation
    def creation
      HistoryNode.new(
        target: target,
        user: UnknownUser.new,
        datetime: target.created_at,
        verb: :created
      )
    end
  end
end
