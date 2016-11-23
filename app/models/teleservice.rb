class Teleservice < ActiveRecord::Base
  include PaperTrailable

  attr_accessible :teleservice_provider_id,
    :teleservice_provider_type,
    :service_type_key,
    :telephone,
    :video,
    :email,
    :store,
    :contact_note

  belongs_to :teleservice_provider, polymorphic: true

  SERVICE_TYPES = {
    1 => "Initial consultation with a patient",
    2 => "Follow-up with a patient",
    3 => "Advice to a health care provider",
    4 => "Case conferencing with a health care provider"
  }

  def name
    Teleservice::SERVICE_TYPES[service_type_key]
  end

  def offered_modalities_list
    telemodalities.
      select(&:offered?).
      map(&:label).
      to_sentence(SentenceHelper.normal_weight_sentence_connectors).
      html_safe
  end


  def offered?
    telemodalities.any?(&:offered?)
  end

  def telemodalities
    @telemodalities ||= Modality.for_service(self)
  end

  class Modality
    KEYS = [
      :telephone,
      :video,
      :email,
      :store
    ]

    def self.for_service(service)
      KEYS.map do |key|
        Modality.new(service, key)
      end
    end

    def initialize(service, key)
      @service = service
      @key = key
    end

    def offered?
      @service.send(@key)
    end

    def label
      if @key == :store
        "store & forward"
      elsif @key == :email
        "email / text"
      else
        @key.to_s
      end
    end
  end
end
