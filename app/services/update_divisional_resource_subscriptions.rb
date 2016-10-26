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
    return unless params[:divisional_resource_subscriptions].present?

    subscription = DivisionalResourceSubscription.find_or_create_by(
      division_id: division.id
    )
    subscription.merge(
      nonspecialized: params[:divisional_resource_subscriptions][0][:nonspecialized],
      specialization_ids: params[:divisional_resource_subscriptions][0][:specialization_ids]
    )
    subscription.save
  end
end
