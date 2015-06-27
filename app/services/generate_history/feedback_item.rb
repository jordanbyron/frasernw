module GenerateHistory
  class FeedbackItem
    include Annotations

    def exec
      [ creation ] + annotations
    end

    def creation
      HistoryNode.new(
        target: target,
        user: target.user,
        datetime: target.created_at,
        verb: :created
      )
    end
  end
end
