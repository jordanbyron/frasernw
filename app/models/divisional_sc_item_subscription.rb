class DivisionalScItemSubscription < ActiveRecord::Base
  attr_accessible :division_id, :nonspecialized, :specialization_ids

  belongs_to :division
  belongs_to :specialization

  def empty?
    specialization_ids.none? && !nonspecialized?
  end

  def all?
    specialization_ids.count == Specialization.all.count &&
      nonspecialized?
  end
end
