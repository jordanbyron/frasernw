import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterCheckbox from "controllers/filter_checkbox";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { sex as subkeys } from "controller_helpers/filter_subkeys";

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
        {
          subkeys(model).map((key) => {
            return(
              <FilterCheckbox
                label={_.capitalize(key)}
                key={key}
                filterKey="sex"
                filterSubkey={key}
                model={model}
                dispatch={dispatch}
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
  "specialists"
]

export default SexFilters;
