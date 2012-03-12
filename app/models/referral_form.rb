class ReferralForm < ActiveRecord::Base
  belongs_to :referrable, :polymorphic => true
  
  has_attached_file :form
  
  has_paper_trail
end
