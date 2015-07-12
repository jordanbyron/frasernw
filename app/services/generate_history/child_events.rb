class GenerateHistory
  # prior to last
  class ChildEvents < Base
    class ReviewItem < Base
      def exec
        return [] unless target.is_a? Reviewable

        target.review_items.inject([]) do |memo, review_item|
          memo + review_item.history
        end
      end
    end

    class FeedbackItem < Base
      def exec
        return [] unless target.is_a? Feedbackable

        target.feedback_items.inject([]) do |memo, feedback_item|
          memo + feedback_item.history
        end
      end
    end

    CHILD_EVENT_TYPES = [
      ReviewItem,
      FeedbackItem
    ]

    def exec
      CHILD_EVENT_TYPES.inject([]) do |memo, event_type|
        memo + event_type.for(target)
      end
    end

  end
end
