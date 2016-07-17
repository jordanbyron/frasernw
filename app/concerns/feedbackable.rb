module Feedbackable
  extend ActiveSupport::Concern

  included do
    has_many :active_feedback_items,
      -> { where "archived" => false },
      as: :target,
      class_name: "FeedbackItem",
      foreign_key: "target_id"
    has_many :feedback_items,
      as: :target,
      foreign_key: "target_id",
      class_name: "FeedbackItem"
  end
end
