class SpecializationOwner < ActiveRecord::Base
  belongs_to :specialization
  belongs_to :owner, :class_name => "User"
  belongs_to :division

  def self.for_division(division)
    where("specialization_owners.division_id = (?)", division.id)
  end

  include PaperTrailable
end
