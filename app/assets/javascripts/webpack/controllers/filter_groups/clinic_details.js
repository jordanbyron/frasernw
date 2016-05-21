import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterCheckbox from "controllers/filter_checkbox";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";

const ClinicDetailsFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Clinic Details"}
        isCollapsible={true}
        expansionControlKey={"clinicDetails"}
        defaultIsExpanded={false}
        model={model}
        dispatch={dispatch}
      >
        <FilterCheckbox
          label={"Public"}
          filterKey="isPublic"
          model={model}
          dispatch={dispatch}
        />
        <FilterCheckbox
          label={"Private"}
          filterKey="isPrivate"
          model={model}
          dispatch={dispatch}
        />
        <FilterCheckbox
          label={"Wheelchair Accessible"}
          filterKey="isWheelchairAccessible"
          model={model}
          dispatch={dispatch}
        />
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
}

const shouldShow = (model) => {
  return _.includes(ROUTES, matchedRoute(model)) &&
    _.includes(COLLECTIONS, collectionShownName(model))
}
const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];
const COLLECTIONS = [
  "clinics"
]

export default ClinicDetailsFilters;
