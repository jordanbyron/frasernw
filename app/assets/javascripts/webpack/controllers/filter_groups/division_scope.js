import React from "react";
import FilterGroup from "component_helpers/filter_group";
import * as FilterValues from "controller_helpers/filter_values";
import { changeFilterValue } from "action_creators";

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

const DivisionScopeFilterController = ({model, dispatch}) => {
  return(
    <FilterGroup title="Scope">
      <label>
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
}

export default DivisionScopeFilterController;
