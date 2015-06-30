module GenerateHistory
  class FeedbackItem
    include Annotations
    include LastUpdated

    def exec
      [ creation, last_updated ] + annotations
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
