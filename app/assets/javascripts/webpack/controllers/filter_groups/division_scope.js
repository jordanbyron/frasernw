import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterSelector from "controllers/filter_selector";
import { route } from "controller_helpers/routing";

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
  return _.includes(ROUTES_IMPLEMENTING, route);
}

const ROUTES_IMPLEMENTING = [
  "/reports/page_views_by_user",
  "/reports/entity_page_views",
  "/reports/profiles_by_specialty"
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
