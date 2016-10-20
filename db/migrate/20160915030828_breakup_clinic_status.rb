class BreakupClinicStatus < ActiveRecord::Migration
  def up
    add_column :clinics, :completed_survey, :boolean, default: true

    add_column :clinics, :accepting_new_referrals, :boolean
    add_column :clinics, :referrals_limited, :boolean

    add_column :clinics, :closure_scheduled, :boolean, default: false
    rename_column :clinics, :unavailable_from, :closure_date

    Clinic.reset_column_information

    Clinic.all.each do |clinic|
      clinic.without_versioning do
        clinic.update_attributes(
          NEW_CLINIC_ATTRIBUTES.map{ |k, v| [ k, v.call(clinic) ] }.to_h
        )
      end
    end

    Clinic.where(completed_survey: false).update_all(hidden: true)
    HidePerenniallyUnavailableProfiles.call
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
    closure_date: ->(clinic){
      if clinic.status_mask == 4
        clinic.closure_date || clinic.event_date do |reified_clinic|
          reified_clinic.status_mask == 4
        end
      else
        nil
      end
    },
    closure_scheduled: ->(clinic){
      clinic.status_mask == 4
    }
  }
end
