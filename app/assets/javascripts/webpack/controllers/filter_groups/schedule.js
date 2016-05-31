import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterCheckbox from "controllers/filter_checkbox";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { scheduleDays as subkeys } from "controller_helpers/filter_subkeys";

const ScheduleFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Schedule"}
        isCollapsible={true}
        expansionControlKey={"schedule"}
        defaultIsExpanded={false}
        model={model}
        dispatch={dispatch}
      >
        {
          subkeys(model).map((key) => {
            return(
              <FilterCheckbox
                label={model.app.dayKeys[key]}
                filterKey={"scheduleDays"}
                filterSubkey={key}
                key={key}
                model={model}
                dispatch={dispatch}
                isHalfColumn={true}
              />
            )
          })
        }
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
};

const shouldShow = (model) => {
  return _.includes(ROUTES, matchedRoute(model)) &&
    _.includes(COLLECTIONS, collectionShownName(model))
}
const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/hospitals/:id",
  "/languages/:id"
];
const COLLECTIONS = [
  "specialists",
  "clinics"
]

export default ScheduleFilters;
