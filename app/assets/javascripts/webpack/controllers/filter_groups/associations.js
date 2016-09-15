import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterSelector from "controllers/filter_selector";
import { route } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";

const AssociationsFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Associations"}
        isCollapsible={true}
        expansionControlKey={"associations"}
        defaultIsExpanded={false}
        model={model}
        dispatch={dispatch}
      >
        <FilterSelector
          label="Clinic"
          filterKey="clinicAssociations"
          options={clinicOptions(model)}
          model={model}
          dispatch={dispatch}
        />
        <HospitalSelector model={model} dispatch={dispatch}/>
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
}

const HospitalSelector = ({model, dispatch}) => {
  if (route === "/hospitals/:id") {
    return <noscript/>
  }
  else {
    return(
      <FilterSelector
        label="Hospital"
        filterKey="hospitalAssociations"
        options={hospitalOptions(model)}
        model={model}
        dispatch={dispatch}
      />
    )
  }
}

const options = (collectionName, model) => {
  return recordsMaskingFilters(model).
    map(_.property(`${collectionName}Ids`)).
    pwPipe(_.flatten).
    pwPipe(_.uniq).
    map((id) => {
      return {
        key: id,
        label: model.app[`${collectionName}s`][id].name
      };
    }).pwPipe((options) => _.sortBy(options, _.property("label")))
    .pwPipe((options) => [{key: 0, label: "Any"}].concat(options))

}

const clinicOptions = _.partial(options, "clinic")
const hospitalOptions = _.partial(options, "hospital")

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
  "specialists"
]

export default AssociationsFilters;
