class FixPracticeDetails < ActiveRecord::Migration
  def up
    Specialist.all.each do |specialist|
      if !specialist.practice_details.present? || specialist.updated_at < Date.new(2016, 11, 6)
        new_practice_details =
          #purposely not surveyed, not responded to survey
          if [1, 2].include?(specialist.categorization_mask)
            specialist.status_details
          else
            # only works out of hospitals and clinics, purposely not surveyed, only accepts referrals through hospitals, clinics
            specialist.hospital_clinic_details
          end

        specialist.update_attributes(practice_details: new_practice_details)
      end
    end
  end
end
