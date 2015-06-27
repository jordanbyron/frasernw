class FeedbackItem < ActiveRecord::Base
  include Noteable

  belongs_to :item, :polymorphic => true

  belongs_to :user

  def label
    "#{item.name} (Feedback Item)"
  end

  class << self
    def active
      includes(:item).where(:archived => false)
    end

    def archived
      includes(:item).where(:archived => true)
    end
  end
end
