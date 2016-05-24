import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterSelector from "controllers/filter_selector";
import { matchedRoute } from "controller_helpers/routing";

const DivisionScopeFilters = ({model, dispatch}) => {
  if(shouldShow(model)){
    return(
      <FilterGroup title="Division Affiliation" isCollapsible={false}>
        <FilterSelector
          label={null}
          filterKey="divisionScope"
          model={model}
          dispatch={dispatch}
          options={scopeOptions(model)}
        />
      </FilterGroup>
    );
  } else {
    return <span></span>
  }
};

const shouldShow = (model) => {
  return _.includes(ROUTES_IMPLEMENTING, matchedRoute(model));
}

const ROUTES_IMPLEMENTING = [
  "/reports/pageviews_by_user",
  "/reports/usage",
  "/reports/referents_by_specialty"
]

const scopeOptions = (model) => {
  if (model.app.currentUser.role === "admin") {
    return model.
      app.
      currentUser.
      divisionIds.concat(0).
      pwPipe(_.partial(labelOptions, model)).
      pwPipe(sortOptions)
  }
  else {
    return _.map(model.app.divisions, _.property("id")).
      concat(0).
      pwPipe(_.partial(labelOptions, model)).
      pwPipe(sortOptions)
  }
}

const labelOptions = (model, options) => {
  return options.map((option) => labelScopeOption(model, option));
}

const sortOptions = (options) => {
  return _.sortBy(options, _.property("label"));
}

const labelScopeOption = (model, option) => {
  if (option === 0) {
    return { key: option, label: "All Divisions" };
  }
  else {
    return { key: option, label: model.app.divisions[option].name };
  }
};


export default DivisionScopeFilters;
