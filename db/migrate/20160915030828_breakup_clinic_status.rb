class BreakupClinicStatus < ActiveRecord::Migration
  def up
    add_column :clinics, :surveyed, :boolean
    add_column :clinics, :responded_to_survey, :boolean

    add_column :clinics, :accepting_new_referrals, :boolean
    add_column :clinics, :referrals_limited, :boolean

    add_column :clinics, :availability, :integer

    Clinic.all.each do |clinic|
      clinic.without_versioning do
        clinic.update_attributes(
          NEW_CLINIC_ATTRIBUTES.map{ |k, v| [ k, v.call(clinic) ] }.to_h
        )
      end

    end
  end

  NEW_SPECIALIST_ATTRIBUTES = {
    surveyed: -> (clinic) {
      clinic.categorization_mask != 3 #purposely not surveyed
    },
    responded_to_survey: ->(clinic) {
      #purposely not surveyed, not responded to survey
      ![2, 3].include?(clinic.categorization_mask)
    },
    accepting_new_referrals: ->(clinic){
      clinic.categorization_mask == 1 && #responded to survey
        [1, 7].include?(clinic.status_mask) #accepting new referrals or referrals limited
    },
    referrals_limited: ->(clinic){
      clinic.categorization_mask == 1 && #responded to survey
        clinic.status_mask == 7 #accepting limited new referrals
    },
    availability: -> (clinic){
      case clinic.status_mask
      when 1 # accepting new referrals
        Specialist::AVAILABILITY_LABELS.key(:available)
      when 2 # only doing follow up
        Specialist::AVAILABILITY_LABELS.key(:available)
      when 4 #retired as of
        Specialist::AVAILABILITY_LABELS.key(:retired)
      when 5 #retiring as of
        Specialist::AVAILABILITY_LABELS.key(:available)
      when 6 #unavailable between
        if clinic.unavailable_from < Date.today && clinic.unavailable_to > Date.today
          Specialist::AVAILABILITY_LABELS.key(:temporarily_unavailable)
        else
          Specialist::AVAILABILITY_LABELS.key(:available)
        end
      when 7 #didn't answer
        Specialist::AVAILABILITY_LABELS.key(:unknown)
      when 8 #indefinitely unavailable
        Specialist::AVAILABILITY_LABELS.key(:indefinitely_unavailable)
      when 9 #permanently unavailable
        Specialist::AVAILABILITY_LABELS.key(:permanently_unavailable)
      when 10 #moved away
        Specialist::AVAILABILITY_LABELS.key(:moved_away)
      when 11 #limited referrals
        Specialist::AVAILABILITY_LABELS.key(:available)
      when 12 #deceased
        Specialist::AVAILABILITY_LABELS.key(:deceased)
      else
        Specialist::AVAILABILITY_LABELS.key(:available)
      end
    }
  }
end
