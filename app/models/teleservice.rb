class Teleservice < ActiveRecord::Base
  attr_accessible :specialist_id,
    :service_type,
    :telephone,
    :video,
    :email,
    :store,
    :contact_note

  belongs_to :specialist

  SERVICE_TYPES = {
    1 => "Initial consultation with a patient",
    2 => "Follow-up with a patient",
    3 => "Advice to a health care provider",
    4 => "Case conferencing with a health care provider"
  }

  def name
    Teleservice::SERVICE_TYPES[service_type]
  end

  def telemodalities
    { telephone: telephone, video: video, email: email, store: store }
  end

end
