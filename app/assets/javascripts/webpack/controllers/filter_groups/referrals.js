import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterCheckbox from "controllers/filter_checkbox";
import FilterSelector from "controllers/filter_selector";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";

const ReferralsFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Referrals"}
        isCollapsible={true}
        expansionControlKey={"referrals"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterCheckbox
          label={"Accepted Via Phone"}
          filterKey="acceptsReferralsViaPhone"
          model={model}
          dispatch={dispatch}
        />
        <FilterSelector
          label="Responded To Within"
          filterKey="respondsWithin"
          options={respondsWithinOptions(model)}
          model={model}
          dispatch={dispatch}
        />
        <FilterCheckbox
          label={"Patients can call to book after referral"}
          filterKey="patientsCanCall"
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

const respondsWithinOptions = (model) => {
  return _.map(model.app.respondsWithinOptions, (label, key) => {
    return {
      key: parseInt(key),
      label: label
    };
  });
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
  "specialists"
];

export default ReferralsFilters;
