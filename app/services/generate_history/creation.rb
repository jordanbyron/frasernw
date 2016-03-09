class GenerateHistory
  class Creation < Base
    def call
      [
        HistoryNode.new(
          target: target,
          user: target.creator,
          datetime: target.created_at,
          verb: :created,
          new_version: target.post_creation_version,
          note: target.is_a?(FeedbackItem) ? target.feedback : nil
        )
      ]
    end
  end
end
