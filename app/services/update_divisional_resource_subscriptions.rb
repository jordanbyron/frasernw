class UpdateDivisionalResourceSubscriptions
  attr_reader :division, :params

  def self.exec(division, params)
    new(division, params).exec
  end

  def initialize(division, params)
    @division = division
    @params = params
  end

  def exec
    return unless params[:divisional_resource_subscription].present?

    subscription = DivisionalResourceSubscription.find_or_create_by(
      division_id: division.id
    )
    specialization_ids =
      params[:divisional_resource_subscription][:specialization_ids].
        reject(&:blank?)
    subscription.update_attributes(
      nonspecialized:
        params[:divisional_resource_subscription][:nonspecialized],
      specialization_ids: specialization_ids
    )
    subscription.save
  end
end
