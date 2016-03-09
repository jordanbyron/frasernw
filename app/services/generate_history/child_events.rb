class GenerateHistory
  # prior to last
  class ChildEvents < Base
    class ReviewItem < Base
      def call
        return [] unless target.is_a? Reviewable

        target.review_items.inject([]) do |memo, review_item|
          memo + review_item.history
        end
      end
    end

    class FeedbackItem < Base
      def call
        return [] unless target.is_a? Feedbackable

        target.feedback_items.inject([]) do |memo, feedback_item|
          memo + feedback_item.history
        end
      end
    end

    class ReferralForm < Base
      def call
        return [] unless target.is_a? Referrable

        target.referral_forms.inject([]) do |memo, referral_form|
          memo + referral_form.history
        end
      end
    end

    class SecretToken < Base
      def call
        return [] unless target.is_a? TokenAccessible

        target.secret_tokens.inject([]) do |memo, secret_token|
          memo + secret_token.history
        end
      end
    end

    CHILD_EVENT_TYPES = [
      ReviewItem,
      FeedbackItem,
      ReferralForm,
      SecretToken
    ]


    def call
      CHILD_EVENT_TYPES.inject([]) do |memo, event_type|
        memo + event_type.call(target: target)
      end
    end

  end
end
