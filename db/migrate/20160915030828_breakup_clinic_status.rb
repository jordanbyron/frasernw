class BreakupClinicStatus < ActiveRecord::Migration
  def up
    add_column :clinics, :completed_survey, :boolean, default: true

    add_column :clinics, :accepting_new_referrals, :boolean
    add_column :clinics, :referrals_limited, :boolean

    add_column :clinics, :closure_scheduled, :boolean
    rename_column :clinics, :unavailable_from, :closure_date

    add_column :clinics, :is_open, :boolean

    Clinic.all.each do |clinic|
      clinic.without_versioning do
        clinic.update_attributes(
          NEW_CLINIC_ATTRIBUTES.map{ |k, v| [ k, v.call(clinic) ] }.to_h
        )
      end
    end

    UpdateClinicClosure.call
    Clinic.where(completed_survey: false).update_all(hidden: true)
  end

  NEW_CLINIC_ATTRIBUTES = {
    completed_survey: ->(clinic){
      #purposely not surveyed, not responded
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
    is_open: ->(clinic){
      case clinic.status_mask
      when 3
        nil
      when nil
        nil
      when 4
        false
      else
        true
      end
    }
  }
end
