import FilterGroup from "controllers/filter_group";
import FilterSelector from "controllers/filter_selector";
import React from "react";
import { matchedRoute } from "controller_helpers/routing";
import monthOptions from "controller_helpers/month_options";

const DateRangeFilters = ({model, dispatch}) => {
  if(matchedRoute(model) === "/reports/usage"){
    return(
      <FilterGroup
        title="Month"
        isCollapsible={true}
        expansionControlKey={"month"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterSelector
          filterKey="startMonth"
          model={model}
          dispatch={dispatch}
          options={monthOptions(2014, 4)}
        />
      </FilterGroup>
    );
  }
  else {
    return <span></span>
  }
};


export default DateRangeFilters;
