class SpecializationOwner < ActiveRecord::Base
  belongs_to :specialization
  belongs_to :owner, :class_name => "User"
  belongs_to :division
  
  has_paper_trail
end
