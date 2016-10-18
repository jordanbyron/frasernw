import updateScheduleDay from
  "window_scripts/referent_forms/setup_visibility_toggles/update_schedule_day";
import updateSpecialistLocation from
  "window_scripts/referent_forms/setup_visibility_toggles/update_specialist_location";
import setupVisibilityToggle from
  "window_scripts/referent_forms/setup_visibility_toggles/setup_visibility_toggle";

export default function specialist(){
  setupGeneralInformation();
  setupSectionToggles();

  $(".scheduled").each(updateScheduleDay)
  $(".scheduled").on("change", updateScheduleDay);

  $(".location_is").each(updateSpecialistLocation);
  $(".location_is").on("change", updateSpecialistLocation);
};

const setupSpecialistVisibilityToggle = _.partialRight(
  setupVisibilityToggle,
  "specialist"
)

const setupGeneralInformation = () => {
  setupSpecialistVisibilityToggle(
    [
      { name: "has_offices", truthyVal: true }
    ],
    "accepting_new_direct_referrals"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "has_offices", truthyVal: true },
      { name: "accepting_new_direct_referrals", truthyVal: true }
    ],
    "direct_referrals_limited"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "retirement_scheduled", truthyVal: true}
    ],
    "retirement_date"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "practice_end_scheduled", truthyVal: true }
    ],
    "practice_end_date"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "practice_end_scheduled", truthyVal: true }
    ],
    "practice_restart_scheduled"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "practice_end_scheduled", truthyVal: true }
      { name: "practice_restart_scheduled", truthyVal: true }
    ],
    "practice_restart_date"
  );
}

const setupSectionToggles = () => {
  setupSpecialistVisibilityToggle(
    [
      { name: "has_offices", truthyVal: true }
    ],
    "section_contact"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "has_offices", truthyVal: true }
    ],
    "section_moa"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "has_offices", truthyVal: true }
    ],
    "section_languages"
  );
  // review
  setupSpecialistVisibilityToggle(
    [
      { name: "has_offices", truthyVal: false },
      { name: "accepting_new_direct_referrals", truthyVal: false },
    ],
    "section_hospital_clinic_details"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "has_offices", truthyVal: true },
      { name: "accepting_new_direct_referrals", truthyVal: true },
    ],
    "section_referrals"
  );
  setupSpecialistVisibilityToggle(
    [
      { name: "has_offices", truthyVal: true }
    ],
    "section_for_patients"
  );
}

export default specialist;
