class BuildTeleservices < ServiceObject
  attribute :specialist, Specialist

  def call
    Teleservice::SERVICE_TYPES.keys.each do |key|
      if !@specialist.teleservices.exists?(service_type: key)
        @specialist.teleservices.build(service_type: key)
      end
    end
  end
end