class BreakupStatus < ActiveRecord::Migration
  def up
    add_column :specialists, :completed_survey, :boolean, default: true

    add_column :specialists, :has_offices, :boolean
    add_column :specialists, :accepting_new_direct_referrals, :boolean
    add_column :specialists, :direct_referrals_limited, :boolean

    rename_column :specialists, :unavailable_from, :practice_end_date
    rename_column :specialists, :unavailable_to, :practice_restart_date

    add_column :specialists, :practice_end_scheduled, :boolean
    add_column :specialists, :practice_restart_scheduled, :boolean

    add_column :specialists, :practice_end_reason_key, :integer, default: 2

    Specialist.reset_column_information

    Specialist.all.each do |specialist|
      specialist.without_versioning do
        specialist.update_attributes(
          NEW_SPECIALIST_ATTRIBUTES.map{ |k, v| [ k, v.call(specialist) ] }.to_h
        )
      end
    end

    # TODO: run this by admins
    Specialist.where(status_mask: nil, categorization_mask: 1).update_all(
      hidden: true
    )
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
    practice_end_reason_key: ->(specialist){
      case specialist.status_mask
      when 1 # accepting new referrals
        nil
      when 2 # only doing follow up
        nil
      when 4 #retired as of
        Specialist::PRACTICE_END_REASONS.key(:retirement)
      when 5 #retiring as of
        Specialist::PRACTICE_END_REASONS.key(:retirement)
      when 6 #unavailable between
        Specialist::PRACTICE_END_REASONS.key(:leave)
      when 7 #didn't answer
        nil
      when 8 #indefinitely unavailable
        Specialist::PRACTICE_END_REASONS.key(:leave)
      when 9 #permanently unavailable
        Specialist::PRACTICE_END_REASONS.key(:retirement)
      when 10 #moved away
        Specialist::PRACTICE_END_REASONS.key(:move_away)
      when 11 #limited referrals
        nil
      when 12 #deceased
        Specialist::PRACTICE_END_REASONS.key(:death)
      when nil
        nil
      else
        raise "shouldn't be here"
      end
    },
    practice_end_scheduled: ->(specialist){
      # retired, retiring, unavailable between, indefinitely unavailable,
      # permanently unavailable, moved away, deceased
      [4, 5, 6, 8, 9, 10, 12].include?(specialist.status_mask)
    },
    practice_end_date: ->(specialist){
      if [4, 5, 6].include?(specialist.status_mask)
        # retired, retiring, unavailable between -- explicit

        raise "no end date specified" if specialist.practice_end_date.nil?

        specialist.practice_end_date
      elsif [8, 9, 10, 12].include?(specialist.status_mask)
        specialist.change_date do |reified_version|
          reified_version.status_mask == specialist.status_mask
        end
      else
        nil
      end
    },
    practice_restart_scheduled: ->(specialist){
      # unavailable_between
      specialist.status_mask == 6
    },
    practice_restart_date: ->(specialist){
      # unavailable_between
      if specialist.status_mask == 6
        specialist.practice_restart_date
      else
        nil
      end
    }
  }
end
