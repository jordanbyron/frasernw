class SeedTeleservices < ServiceObject
  def call
    [
      Specialist,
      Clinic
    ].each do |klass|
      klass.all.each do |provider|
        seed(provider)
      end
    end
  end

  def seed(provider)
    BuildTeleservices.call(provider: provider)

    provider.teleservices.each do |service|
      Teleservice::Modality::KEYS.each do |key|
        service.send("#{key}=", (rand() < 0.15))
      end
    end

    provider.save
  end
end
