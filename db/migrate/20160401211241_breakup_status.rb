class BreakupStatus < ActiveRecord::Migration
  def up
    add_column :specialist, :accepting_new_referrals, :boolean
    add_column :specialist, :referrals_limited, :boolean
    add_column :specialist, :indirect_referrals_only, :boolean
    add_column :specialist, :has_own_offices, :boolean
    add_column :specialist, :surveyed, :boolean
    add_column :specialist, :responded_to_survey, :boolean
    add_column :specialist, :retirement_date, :date
    add_column :specialist, :availability, :integer

    Specialist.all.each do |specialist|
      specialist.without_versioning do
        new_attributes = new_status_attributes(specialist).
          merge(new_categorization_attributes(specialist))

        specialist.update_attributes(new_attributes)
      end
    end
  end

  def specialist_status_attributes(specialist)
    case specialist.status_mask
    case 1 # accepting new referrals
      {
        availability: 13,
        retirement_date: nil
      }
    case 2 # only doing follow up
      {
        availability: 13,
        retirement_date: nil
      }
    case 4 #retired as of
      {
        availability: 4, #retired
        retirement_date: specialist.unavailable_from
      }
    case 5 #retiring as of
      {
        availability: 13,
        retirement_date: specialist.unavailable_from
      }
    case 6 #unavailable between
      if specialist.unavailable_from < Date.today && specialist.unavailable_to > Date.today
        {
          availability: 14, #unknown
          retirement_date: nil
        }
      else
        {
          availability: 4, #unknown
          retirement_date: nil
        }
      end
    case 7 #didn't answer
      {
        availability: 7, #unknown
        retirement_date: nil
      }
    case 8 #indefinitely unavailable
      {
        availability: 8,
        retirement_date: nil
      }
    case 9 #permanently unavailable
      {
        availability: 9,
        retirement_date: nil
      }
    case 10 #moved away
      {
        availability: 10,
        retirement_date: nil
      }
    case 11 #limited referrals
      {
        availability: 13,
        retirement_date: nil
      }
    case 12 #deceased
      {
        availability: 12,
        retirement_date: nil
      }
    else
      {
        availability: 13, #available
        retirement_date: nil
      }
    end
  end

  def specialist_categorization_attributes(specialist)
    case specialist.categorization_mask
    when 1
      {
        accepting_new_referrals: [1, 11].include?(specialist.status_mask),
        referrals_limited: (specialist.status_mask == 11),
        indirect_referrals_only: false
        has_own_offices: true,
        surveyed: true,
        responded_to_survey: true
      }
    when 2
      {
        accepting_new_referrals: [1, 11].include?(specialist.status_mask),
        referrals_limited: (specialist.status_mask == 11),
        indirect_referrals_only: false,
        has_own_offices: specialist.specialist_offices.any?(&:has_data?),
        surveyed: true,
        responded_to_survey: false
      }
    when 3
      {
        accepting_new_referrals: nil,
        referrals_limited: nil,
        indirect_referrals_only: true,
        has_own_offices: false,
        surveyed: true,
        responded_to_survey: true
      }
    when 4
      {
        accepting_new_referrals: nil,
        referrals_limited: nil,
        indirect_referrals_only: nil,
        has_own_offices: false,
        surveyed: false,
        responded_to_survey: false
      }
    when 5
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

  def down
  end
end
