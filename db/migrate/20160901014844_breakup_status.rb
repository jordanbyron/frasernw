class BreakupStatus < ActiveRecord::Migration
  def up
    add_column :specialist, :accepting_new_referrals, :boolean
    add_column :specialist, :referrals_limited, :boolean
    add_column :specialist, :indirect_referrals_only, :boolean
    add_column :specialist, :has_own_offices, :boolean
    add_column :specialist, :surveyed, :boolean
    add_column :specialist, :responded_to_survey, :boolean
    add_column :specialist, :availability, :integer
    add_column :specialist, :retirement_date, :date

    Specialist.all.each do |specialist|
      specialist.without_versioning do
        specialist.update_attributes(
          specialist_status_attributes(specialist).
            merge(specialist_categorization_attributes(specialist))
        )
      end
    end
  end

  def specialist_categorization_attributes(specialist)
    case specialist.categorization_mask
    when 1 # responded to survey
      {
        accepting_new_referrals: [1, 11].include?(specialist.status_mask),
        referrals_limited: (specialist.status_mask == 11),
        indirect_referrals_only: false
        has_own_offices: true,
        surveyed: true,
        responded_to_survey: true
      }
    when 2 # not responded to survey
      {
        accepting_new_referrals: [1, 11].include?(specialist.status_mask),
        referrals_limited: (specialist.status_mask == 11),
        indirect_referrals_only: false,
        has_own_offices: specialist.specialist_offices.any?(&:has_data?),
        surveyed: true,
        responded_to_survey: false
      }
    when 3 # only works out of hospitals or clinics
      {
        accepting_new_referrals: nil,
        referrals_limited: nil,
        indirect_referrals_only: true,
        has_own_offices: false,
        surveyed: true,
        responded_to_survey: true
      }
    when 4 # purposely not surveyed
      {
        accepting_new_referrals: nil,
        referrals_limited: nil,
        indirect_referrals_only: nil,
        has_own_offices: false,
        surveyed: false,
        responded_to_survey: false
      }
    when 5 # only accepts referrals through hospitals or clinics
      {
        accepting_new_referrals: nil,
        referrals_limited: nil,
        indirect_referrals_only: true,
        has_own_offices: specialist.specialist_offices.any?(&:has_data?),
        surveyed: true,
        responded_to_survey: true
      }
    else
      raise "This should never happen"
    end
  end

  def specialist_status_attributes(specialist)
    case specialist.status_mask
    case 1 # accepting new referrals
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:available),
      }
    case 2 # only doing follow up
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:available),
      }
    case 4 #retired as of
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:retired),
      }
    case 5 #retiring as of
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:available),
      }
    case 6 #unavailable between
      if specialist.unavailable_from < Date.today && specialist.unavailable_to > Date.today
        {
          availability: Specialist::AVAILABILITY_LABELS.key(:temporarily_unavailable),
        }
      else
        {
          availability: Specialist::AVAILABILITY_LABELS.key(:available),
        }
      end
    case 7 #didn't answer
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:unknown),
      }
    case 8 #indefinitely unavailable
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:indefinitely_unavailable),
      }
    case 9 #permanently unavailable
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:permanently_unavailable),
      }
    case 10 #moved away
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:moved_away),
      }
    case 11 #limited referrals
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:available),
      }
    case 12 #deceased
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:deceased),
      }
    else
      {
        availability: Specialist::AVAILABILITY_LABELS.key(:available), #available
      }
    end
  end
end
