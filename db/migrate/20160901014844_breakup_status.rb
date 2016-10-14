class BreakupStatus < ActiveRecord::Migration
  def up
    add_column :specialists, :completed_survey, :boolean

    add_column :specialists, :has_offices, :boolean
    add_column :specialists, :accepting_new_direct_referrals, :boolean
    add_column :specialists, :direct_referrals_limited, :boolean

    add_column :specialists, :availability, :integer

    add_column :specialists, :retirement_scheduled, :boolean
    add_column :specialists, :retirement_date, :date

    add_column :specialists, :leave_scheduled, :boolean

    Specialist.all.each do |specialist|
      specialist.without_versioning do
        specialist.update_attributes(
          NEW_SPECIALIST_ATTRIBUTES.map{ |k, v| [ k, v.call(specialist) ] }.to_h
        )
      end

    end

    UpdateSpecialistAvailability.call
    Specialist.where(completed_survey: false).update_all(hidden: true)
  end

  NEW_SPECIALIST_ATTRIBUTES = {
    completed_survey: ->(specialist) {
      #purposely not surveyed, not responded to survey
      ![4, 2].include?(specialist.categorization_mask)
    },
    accepting_new_direct_referrals: ->(specialist){
      specialist.categorization_mask == 1 && #responded to survey
        specialist.specialist_offices.select(&:has_data?).any? &&
        [1, 11].include?(specialist.status_mask) #accepting new referrals, referrals limited
    },
    direct_referrals_limited: ->(specialist){
      specialist.categorization_mask == 1 && #responded to survey
        specialist.specialist_offices.select(&:has_data?).any? &&
        specialist.status_mask == 11 #accepting limited new referrals
    },
    has_offices: -> (specialist){
       #responded to survey, only accepts referrals through hospitals, clinics
      [1, 5].include?(specialist.categorization_mask) &&
        specialist.specialist_offices.select(&:has_data?).any?
    },
    availability: -> (specialist){
      case specialist.status_mask
      when 1 # accepting new referrals
        Specialist::AVAILABILITY_LABELS.key(:available_for_work)
      when 2 # only doing follow up
        Specialist::AVAILABILITY_LABELS.key(:available_for_work)
      when 4 #retired as of
        Specialist::AVAILABILITY_LABELS.key(:retired)
      when 5 #retiring as of
        Specialist::AVAILABILITY_LABELS.key(:available_for_work)
      when 6 #unavailable between
        if specialist.unavailable_from < Date.today && specialist.unavailable_to > Date.today
          Specialist::AVAILABILITY_LABELS.key(:temporarily_unavailable)
        else
          Specialist::AVAILABILITY_LABELS.key(:available_for_work)
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
        Specialist::AVAILABILITY_LABELS.key(:available_for_work)
      when 12 #deceased
        Specialist::AVAILABILITY_LABELS.key(:deceased)
      else
        Specialist::AVAILABILITY_LABELS.key(:available_for_work)
      end
    },
    retirement_date: ->(specialist){
      if [4, 5].include?(specialist.status_mask) #retiring as of, retired as of
        specialist.unavailable_from
      else
        nil
      end
    },
    retirement_scheduled: ->(specialist){
      [4, 5].include?(specialist.status_mask) #retiring as of, retired as of
    },
    leave_scheduled: ->(specialist){
      specialist.status_mask == 6 #unavailable between
    }
  }
end
