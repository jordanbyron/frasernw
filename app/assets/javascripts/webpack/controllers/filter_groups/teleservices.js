import React from "react";
import FilterGroup from "controllers/filter_group";
import NestedFilterCheckbox from "controllers/nested_filter_checkbox";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";

const TeleserviceFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Telehealth Services"}
        isCollapsible={true}
        expansionControlKey={"teleservices"}
        defaultIsExpanded={false}
        model={model}
        dispatch={dispatch}
      >
        <NestedFilterCheckbox
          label="Telehealth patient services"
          filterKey="teleserviceRecipients"
          filterSubkey="patient"
          key="patient"
          model={model}
          dispatch={dispatch}
        >
          <NestedFilterCheckbox
            filterKey="teleserviceFeeTypes"
            filterSubkey={1}
            key={1}
            label="Initial consultation with a patient"
            model={model}
            dispatch={dispatch}
          />
          <NestedFilterCheckbox
            filterKey="teleserviceFeeTypes"
            filterSubkey={2}
            key={2}
            label="Follow-up with a patient"
            model={model}
            dispatch={dispatch}
          />
        </NestedFilterCheckbox>
        <NestedFilterCheckbox
          label="Telehealth provider services"
          filterKey="teleserviceRecipients"
          filterSubkey="provider"
          key="provider"
          model={model}
          dispatch={dispatch}
        >
          <NestedFilterCheckbox
            filterKey="teleserviceFeeTypes"
            filterSubkey={3}
            key={3}
            label="Advice to a health care provider"
            model={model}
            dispatch={dispatch}
          />
          <NestedFilterCheckbox
            filterKey="teleserviceFeeTypes"
            filterSubkey={4}
            key={4}
            label="Case conferencing with a health care provider"
            model={model}
            dispatch={dispatch}
          />
        </NestedFilterCheckbox>
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
  "specialists",
  "clinics"
]

export default TeleserviceFilters;
