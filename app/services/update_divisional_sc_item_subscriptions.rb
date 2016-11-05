class UpdateDivisionalScItemSubscriptions < ServiceObject
  attribute :division
  attribute :params

  def call
    return unless params[:divisional_sc_item_subscription].present?

    subscription = DivisionalScItemSubscription.find_or_create_by(
      division_id: division.id
    )
    specialization_ids =
      params[:divisional_sc_item_subscription][:specialization_ids].
        reject(&:blank?)
    subscription.update_attributes(
      nonspecialized:
        params[:divisional_sc_item_subscription][:nonspecialized],
      specialization_ids: specialization_ids
    )
    subscription.save
  end
end
