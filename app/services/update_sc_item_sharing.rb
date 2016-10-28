class UpdateScItemSharing < ServiceObject
  attribute :is_shared, Axiom::Types::Boolean
  attribute :division, Division
  attribute :sc_item, ScItem
  attribute :current_user, User

  def call
    if (
      current_user.as_super_admin? ||
        current_user.as_divisions.include?(division)
    )
      update_shared(sc_item, is_shared, division.id)
    else
      false
    end
  end

  def fulfill_divisional_resource_subscriptions(sc_item)
    if sc_item.shareable? && (sc_item.division_id == Division.provincial.id)
      specialization_ids = sc_item.specializations.map(&:id)
      DivisionalResourceSubscription.select do |subscription|
        (subscription.nonspecialized? && specialization_ids.none?) ||
          (subscription.specialization_ids & specialization_ids).any?
      end.each do |subscription|
        update_shared(sc_item, true, subscription.division_id)
      end
    end
  end

  private

  def update_shared(sc_item, is_shared, division_id)
    existing_record =
      DivisionDisplayScItem.
        where(sc_item_id: sc_item.id, division_id: division_id).
        first
    if is_shared && !existing_record.present?
      DivisionDisplayScItem.create(
        sc_item_id: sc_item.id,
        division_id: division_id
      )
    elsif !is_shared && existing_record.present?
      existing_record.destroy
    end
    true
  end
end
