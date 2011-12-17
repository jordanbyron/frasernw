class HospitalAddress < ActiveRecord::Base
  belongs_to :hospital
  belongs_to :address
end
