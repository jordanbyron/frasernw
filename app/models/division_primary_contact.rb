class DivisionPrimaryContact < ActiveRecord::Base
  belongs_to :division
  belongs_to :primary_contact, :class_name => 'User'
  
  has_paper_trail
end
