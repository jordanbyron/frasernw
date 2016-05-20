import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterCheckbox from "controllers/filter_checkbox";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";

const SexFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Sex"}
        isCollapsible={true}
        expansionControlKey={"sex"}
        defaultIsExpanded={false}
        model={model}
        dispatch={dispatch}
      >
        <FilterCheckbox
          label="Male"
          filterKey="sex"
          filterSubkey="male"
          model={model}
          dispatch={dispatch}
          isHalfColumn={true}
        />
        <FilterCheckbox
          label="Female"
          filterKey="sex"
          filterSubkey="female"
          model={model}
          dispatch={dispatch}
          isHalfColumn={true}
        />
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
  "/areas_of_practice/:id"
];
const COLLECTIONS = [
  "specialists"
]

export default SexFilters;
