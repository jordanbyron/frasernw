class FeedbackItem < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  
  belongs_to :user
  
  class << self
    def active
      where(:archived => false)
    end
    
    def archived
      where(:archived => true)
    end
  end
end
