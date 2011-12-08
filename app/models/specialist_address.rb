class SpecialistAddress < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :address
end
