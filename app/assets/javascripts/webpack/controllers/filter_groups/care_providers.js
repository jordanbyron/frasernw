import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterCheckbox from "controllers/filter_checkbox";
import { route } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { careProviders as subkeys } from "controller_helpers/filter_subkeys";

const CareProvidersFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Care Providers"}
        isCollapsible={true}
        expansionControlKey={"careProviders"}
        defaultIsExpanded={false}
        model={model}
        dispatch={dispatch}
      >
        {
          subkeys(model).map((key) => {
            return(
              <FilterCheckbox
                label={model.app.careProviders[key].name}
                filterKey={"careProviders"}
                filterSubkey={key}
                key={key}
                model={model}
                dispatch={dispatch}
              />
            )
          }).pwPipe((checkBoxes) => {
            return _.sortBy(checkBoxes, _.property("props.label"));
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
  return _.includes(ROUTES, route) &&
    _.includes(COLLECTIONS, collectionShownName(model))
}
const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/hospitals/:id",
  "/languages/:id"
];
const COLLECTIONS = [
  "clinics"
];

export default CareProvidersFilters;
