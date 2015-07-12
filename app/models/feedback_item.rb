class FeedbackItem < ActiveRecord::Base
  include Noteable
  include Historical
  include PaperTrailable
  include Archivable

  belongs_to :item, :polymorphic => true

  belongs_to :user

  attr_accessible :feedback, :item_type, :item_id

  def label
    "#{item.name} (Feedback Item)"
  end

  def creator
    user
  end

  def active?
    !archived?
  end
end
