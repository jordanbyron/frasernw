import updateScheduleDay from
  "window_scripts/profile_forms/setup_visibility_toggles/update_schedule_day";
import updateClinicLocation from
  "window_scripts/profile_forms/setup_visibility_toggles/update_clinic_location";
import setupVisibilityToggle from
  "window_scripts/profile_forms/setup_visibility_toggles/setup_visibility_toggle";

export default function clinic() {
  setupGeneralInformation();
  setupSections();

  $(".scheduled").each(updateScheduleDay)
  $(".scheduled").on("change", updateScheduleDay);

  $(".is_specialist").each(updateAttendances);
  $(".is_specialist").on("change", updateAttendances);

  $(".location_is").each(updateClinicLocation);
  $(".location_is").on("change", updateClinicLocation);
}

const setupClinicVisibilityToggle = _.partialRight(
  setupVisibilityToggle,
  "clinic"
);

const setupGeneralInformation = () => {
  setupClinicVisibilityToggle(
    [
      { name: "accepting_new_referrals", truthyVal: true }
    ],
    "referrals_limited"
  );

  setupClinicVisibilityToggle(
    [
      { name: "closure_scheduled", truthyVal: true }
    ],
    "closure_date"
  );
};

const setupSections = () => {
  [
    "section_contact",
    "section_moa",
    "section_status",
    "section_referrals",
    "section_for_patients"
  ].forEach((section) => {
    setupClinicVisibilityToggle(
      [
        { name: "completed_survey", truthyVal: true }
      ],
      section
    )
  })
};

const updateAttendances = function(){
  var currentId = $(this).attr('id');

  var specialists = "#" + currentId.replace("is_specialist","specialist_id");
  var firstname = "#" + currentId.replace("is_specialist","freeform_firstname");
  var lastname = "#" + currentId.replace("is_specialist","freeform_lastname");

  if ( $(this).is(":checked") )
  {
    //we have indicated a specialist
    $(specialists).show();
    $(firstname).hide();
    $(lastname).hide();
  }
  else
  {
    //we have indicated a freeform answer
    $(specialists).hide();
    $(firstname).show();
    $(lastname).show();
  }
};
