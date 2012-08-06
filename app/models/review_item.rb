class ReviewItem < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  
  class << self
    def active
      where(:archived => false)
    end
    
    def archived
      where(:archived => true)
    end
  end
end
