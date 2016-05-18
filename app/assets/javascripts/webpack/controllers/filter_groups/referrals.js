import React from "react";
import FilterGroup from "controllers/filter_group";
import { matchedRoute } from "controller_helpers/routing";

const ReferralsFilters = ({model, dispatch}) => {
  if (_.includes(ROUTES, matchedRoute(model))){
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

const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];

export default ReferralsFilters;
