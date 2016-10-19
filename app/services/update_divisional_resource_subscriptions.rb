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

    division.divisional_resource_subscriptions.each do |subscription|
      if params[:divisional_resource_subscriptions][subscription.specialization_id.to_s] == "0"
        subscription.destroy
      end
    end
    params[:divisional_resource_subscriptions].each do |checkbox_key, value|
      if value == "1"
        subscription = DivisionalResourceSubscription.find_or_create_by(
          division_id: division.id,
          specialization_id: checkbox_key
        )
        subscription.save
      end
    end
  end
end
