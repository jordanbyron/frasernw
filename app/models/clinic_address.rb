class ClinicAddress < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :address
end
