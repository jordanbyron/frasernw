import React from "react";
import FilterGroup from "controllers/filter_group";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";

const ReferralsFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Referrals"}
        isExpandable={true}
        expansionControlKey={"referrals"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <div></div>
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
  "specialists",
  "clinics"
]

export default ReferralsFilters;
