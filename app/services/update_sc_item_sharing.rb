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
      update_shared(:is_shared, :division)
    else
      false
    end
  end

  def update_divisional_resource_subscriptions
    if sc_item.shareable? && (sc_item.division_id == Division.provincial.id)
      specialization_ids = sc_item.specializations.map(&:id)
      DivisionalResourceSubscription.select do |subscription|
        specialization_ids.include?(subscription.specialization_id)
      end.each do |subscription|
        update_shared(is_shared: true, division: subscription.division_id)
      end
    end
  end

  private

  def update_shared(is_shared, division)
    existing_record =
      DivisionDisplayScItem.
        where(sc_item_id: sc_item.id, division_id: division.id).
        first
    if is_shared && !existing_record.present?
      DivisionDisplayScItem.create(
        sc_item_id: sc_item.id,
        division_id: division.id
      )
    elsif !is_shared && existing_record.present?
      existing_record.destroy
    end
    true
  end
end
