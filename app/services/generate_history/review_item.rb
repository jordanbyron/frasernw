module GenerateHistory
  class ReviewItem < Base
    include Annotations

    def exec
      [ creation ] + annotations
    end

    def creation
      HistoryNode.new(
        target: target,
        user: (target.whodunnit || UnauthenticatedUser.new),
        datetime: target.created_at,
        verb: :created
      )
    end
  end
end
