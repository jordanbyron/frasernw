class BreakupStatus < ActiveRecord::Migration
  def up
    add_column :specialists, :surveyed, :boolean
    add_column :specialists, :responded_to_survey, :boolean

    add_column :specialists, :has_own_offices
    add_column :specialists, :accepting_new_direct_referrals, :boolean
    add_column :specialists, :direct_referrals_limited, :boolean

    add_column :specialists, :availability, :integer
    add_column :specialists, :retirement_date, :date

    Specialist.all.each do |specialist|
      specialist.without_versioning do
        specialist.update_attributes(
          NEW_SPECIALIST_ATTRIBUTES.map{ |k, v| [ k, v.call(specialist) ] }.to_h
        )
      end
    end
  end

  NEW_SPECIALIST_ATTRIBUTES = {
    surveyed: -> (specialist) {
      specialist.categorization_mask != 4 #purposely not surveyed
    },
    responded_to_survey: ->(specialist) {
      #purposely not surveyed, not responded to survey
      ![4, 2].include?(specialist.categorization_mask)
    },
    accepting_new_direct_referrals: ->(specialist){
      specialist.categorization_mask == 1 && #responded to survey
        specialist.specialist_offices.select(&:has_data?).any? &&
        specialist.status_mask == 1 #accepting new referrals
    },
    direct_referrals_limited: ->(specialist){
      specialist.categorization_mask == 1 && #responded to survey
        specialist.specialist_offices.select(&:has_data?).any? &&
        specialist.status_mask == 11 #accepting limited new referrals
    },
    has_own_offices: -> (specialist){
       #responded to survey, only accepts referrals through hospitals, clinics
      [1, 5].include?(specialist.categorization_mask) &&
        specialist.specialist_offices.select(&:has_data?).any?
    },
    availability: -> (specialist){
      case specialist.status_mask
      when 1 # accepting new referrals
        Specialist::AVAILABILITY_LABELS.key(:available),
      when 2 # only doing follow up
        Specialist::AVAILABILITY_LABELS.key(:available),
      case 4 #retired as of
        Specialist::AVAILABILITY_LABELS.key(:retired),
      case 5 #retiring as of
        Specialist::AVAILABILITY_LABELS.key(:available),
      case 6 #unavailable between
        if specialist.unavailable_from < Date.today && specialist.unavailable_to > Date.today
          Specialist::AVAILABILITY_LABELS.key(:temporarily_unavailable),
        else
          Specialist::AVAILABILITY_LABELS.key(:available),
        end
      case 7 #didn't answer
        Specialist::AVAILABILITY_LABELS.key(:unknown),
      case 8 #indefinitely unavailable
        Specialist::AVAILABILITY_LABELS.key(:indefinitely_unavailable),
      case 9 #permanently unavailable
        Specialist::AVAILABILITY_LABELS.key(:permanently_unavailable),
      case 10 #moved away
        Specialist::AVAILABILITY_LABELS.key(:moved_away),
      case 11 #limited referrals
        Specialist::AVAILABILITY_LABELS.key(:available),
      case 12 #deceased
        Specialist::AVAILABILITY_LABELS.key(:deceased),
      else
        Specialist::AVAILABILITY_LABELS.key(:available)
      end
    },
    retirement_date: ->(specialist){
      if [4, 5].include?(specialist.status_mask) #retiring as of, retired as of
        specialist.unavailable_from
      else
        nil
      end
    }
  }
end
