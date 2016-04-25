class BuildTeleservices < ServiceObject
  attribute :provider, OffersTeleservices

  def call
    Teleservice::SERVICE_TYPES.keys.each do |key|
      if !provider.teleservices.exists?(service_type: key)
        provider.teleservices.build(service_type: key)
      end
    end
  end
end