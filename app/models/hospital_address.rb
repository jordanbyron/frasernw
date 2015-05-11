class HospitalAddress < ActiveRecord::Base
  belongs_to :hospital
  belongs_to :address

  has_paper_trail
end
