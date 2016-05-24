import React from "react";
import FilterGroup from "controllers/filter_group";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import FilterRadioButtons from "controllers/filter_radio_buttons";

const EntityTypeFilters = ({model, dispatch}) => {
  if (shouldShow(model)) {
    return(
      <FilterGroup
        title={"Entity Type"}
        isCollapsible={true}
        expansionControlKey={"entityType"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterRadioButtons
          filterKey="entityType"
          options={radioOptions(model)}
          model={model}
          dispatch={dispatch}
        />
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
};

const shouldShow = (model) => {
  return _.includes(ROUTES_IMPLEMENTING, matchedRoute(model));
}

const ROUTES_IMPLEMENTING = [
  "/reports/usage",
  "/reports/referents_by_specialty"
]

const OPTION_LABELS = {
  specialists: "Specialists",
  clinics: "Clinics",
  specialties: "Specialties",
  physicianResources: "Physician Resources",
  patientInfo: "Patient Info",
  forms: "Forms",
  redFlags: "Red Flags",
  communityServices: "Community Services",
  pearls: "Pearls"
}

const radioOptionKeys = (model) => {
  if(matchedRoute(model) === "/reports/usage"){
    return _.keys(OPTION_LABELS)
  }
  else if (matchedRoute(model) === "/reports/referents_by_specialty") {
    return [
      "specialists",
      "clinics"
    ];
  }
}

const radioOptions = (model) => {
  return radioOptionKeys(model).map((option) => {
    return {
      key: option,
      label: OPTION_LABELS[option]
    }
  });
};

export default EntityTypeFilters;
