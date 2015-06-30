module GenerateHistory
  class ReviewItem < Base
    include Annotations
    include LastUpdated

    def exec
      [ creation, last_updated] + annotations
    end

    def creation
      HistoryNode.new(
        target: target,
        user: User.safe_find(target.whodunnit),
        datetime: target.created_at,
        verb: :created
      )
    end
  end
end
