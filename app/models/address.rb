class Address < ActiveRecord::Base
  has_paper_trail
  belongs_to :hospital
end
