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
    1 => "Initial consultation with patient",
    2 => "Follow-up with patient",
    3 => "Advice to another health care provider",
    4 => "Case conferencing with a health care provider"
  }

  def name
    Teleservice::SERVICE_TYPES[service_type]
  end

end
