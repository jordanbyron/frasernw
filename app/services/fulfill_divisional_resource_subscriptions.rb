class FulfillDivisionalResourceSubscriptions < ServiceObject
  attribute :sc_item, ScItem

  def call
    if sc_item.borrowable? && (sc_item.division_id == Division.provincial.id)
      specialization_ids = sc_item.specializations.map(&:id)
      DivisionalResourceSubscription.select do |subscription|
        (subscription.nonspecialized? && specialization_ids.none?) ||
          (subscription.specialization_ids & specialization_ids).any?
      end.each do |subscription|
        UpdateScItemBorrowing.call(
          sc_item: sc_item,
          is_borrowed: true,
          division_id: subscription.division_id
        )
      end
    end
  end

end
