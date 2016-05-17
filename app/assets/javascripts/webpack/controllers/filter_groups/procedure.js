import React from "react";
import FilterGroup from "component_helpers/filter_group";
import { matchedRoute } from "controller_helpers/routing";
import { selectedPanelKey } from "controller_helpers/panel_keys";
import { toggleFilterGroupExpansion } from "action_creators";
import _ from "lodash";

const ProcedureFilters = ({model, dispatch}) => {
  if (_.includes(ROUTES, matchedRoute(model))){
    return(
      <FilterGroup
        title={title(model)}
        isExpandable={true}
        isExpanded={isExpanded(model)}
        toggleExpansion={
          _.partial(
            toggleFilterGroupExpansion,
            dispatch,
            selectedPanelKey(model),
            "procedures",
            !isExpanded(model)
          )
        }
      >
        { "test" }
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
]

const isExpanded = (model) => {
  return _.get(
    model,
    ["ui", "panels", selectedPanelKey(model), "isFilterGroupExpanded", "procedures"],
    true
  );
}

const title = (model) => {
  if (matchedRoute(model) === "/specialties/:id"){
    return "Accepts referrals for";
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id") {
    return "Sub-Areas of Practice";
  }
}

export default ProcedureFilters;
