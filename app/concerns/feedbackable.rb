module Feedbackable
  extend ActiveSupport::Concern

  included do
    has_many :active_feedback_items,
      -> { where "archived" => false },
      as: :item,
      class_name: "FeedbackItem",
      foreign_key: "item_id"
    has_many :feedback_items,
      as: :item,
      foreign_key: "item_id",
      class_name: "FeedbackItem"
  end
end
