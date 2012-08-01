class SpecializationOwner < ActiveRecord::Base
  belongs_to :specialization
  belongs_to :owner, :class_name => "User"
  
  has_paper_trail
end
