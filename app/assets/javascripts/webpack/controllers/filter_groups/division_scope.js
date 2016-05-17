import React from "react";
import FilterGroup from "component_helpers/filter_group";
import * as FilterValues from "controller_helpers/filter_values";
import { changeFilterValue } from "action_creators";
import { matchedRoute } from "controller_helpers/routing";

const scopeOptions = (model) => {
  if (model.app.currentUser.role === "admin") {
    return model.app.currentUser.divisionIds.concat(0);
  }
  else {
    return _.map(model.app.divisions, _.property("id")).concat(0);
  }
}

const labelScopeOption = (option, model) => {
  if (option === 0) {
    return "All Divisions";
  }
  else {
    return model.app.divisions[option].name;
  }
}

const DivisionScopeFilters = ({model, dispatch}) => {
  if(matchedRoute(model) === "/reports/pageviews_by_user"){
    return(
      <FilterGroup title="Scope">
        <label style={{marginTop: "10px"}}>
          <select
            value={FilterValues.divisionScope(model)}
            onChange={function(e) { changeFilterValue(dispatch, "divisionScope", e.target.value) } }
          >
            {
              scopeOptions(model).map((option) => {
                return(
                  <option key={option} value={option}>
                    { labelScopeOption(option, model) }
                  </option>
                )
              })
            }
          </select>
        </label>
      </FilterGroup>
    );
  } else {
    return <span></span>
  }
}

export default DivisionScopeFilters;
