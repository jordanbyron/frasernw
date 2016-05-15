class ClinicAddress < ActiveRecord::Base
  attr_accessible :phone,
    :phone_extension,
    :fax,
    :direct_phone,
    :direct_phone_extension,
    :sector_mask,
    :email,
    :open_saturday,
    :open_sunday,
    :office_id,
    :office_attributes,
    :phone_schedule_attributes,
    :url

  belongs_to :clinic
  belongs_to :address

  include PaperTrailable
end
