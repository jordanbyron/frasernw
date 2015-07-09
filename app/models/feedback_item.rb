class FeedbackItem < ActiveRecord::Base
  include Noteable
  include Historical
  include PaperTrailable
  include Archivable

  belongs_to :item, :polymorphic => true

  belongs_to :user

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
