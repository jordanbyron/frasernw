class FeedbackItem < ActiveRecord::Base
  belongs_to :item, :polymorphic => true

  has_many :notes, as: :noteable

  belongs_to :user

  class << self
    def active
      includes(:item).where(:archived => false)
    end

    def archived
      includes(:item).where(:archived => true)
    end
  end
end
