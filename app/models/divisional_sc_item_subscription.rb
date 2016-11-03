class DivisionalScItemSubscription < ActiveRecord::Base
  attr_accessible :division_id, :nonspecialized, :specialization_ids

  belongs_to :division

  def specializations
    @specializations ||= Specialization.find(specialization_ids)
  end

  def empty?
    specialization_ids.none? && !nonspecialized?
  end

  def all?
    specialization_ids.count == Specialization.all.count &&
      nonspecialized?
  end

  def items_captured
    Division.provincial.sc_items.includes(:specializations).select do |sc_item|
      (nonspecialized && sc_item.specializations.none?) ||
        (specializations & sc_item.specializations).any?
    end
  end

  def borrow_existing!
    items_captured.each do |sc_item|
      UpdateScItemBorrowing.call(
        sc_item: sc_item,
        is_borrowed: true,
        division_id: division.id
      )
    end
  end
end
