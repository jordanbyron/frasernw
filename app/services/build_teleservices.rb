class BuildTeleservices < ServiceObject
  attribute :provider, OffersTeleservices

  def call
    Teleservice::SERVICE_TYPES.keys.each do |key|
      if provider.teleservices.none?{|service| service.service_type_key == key }
        provider.teleservices.build(service_type_key: key)
      end
    end
  end
end
