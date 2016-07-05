import FilterGroup from "controllers/filter_group";
import FilterSelector from "controllers/filter_selector";
import React from "react";
import { matchedRoute } from "controller_helpers/routing";
import monthOptions from "controller_helpers/month_options";

const DateRangeFilters = ({model, dispatch}) => {
  if(_.includes(["/reports/pageviews_by_user", "/reports/entity_page_views"],
    matchedRoute(model)
  )){
    return(
      <FilterGroup title="Date Range" isCollapsible={false}>
        <FilterSelector
          label="Start Month:"
          filterKey="startMonth"
          model={model}
          dispatch={dispatch}
          options={monthOptions(2014, 1)}
        />
        <FilterSelector
          label="End Month:"
          filterKey="endMonth"
          model={model}
          dispatch={dispatch}
          options={monthOptions(2014, 1)}
        />
      </FilterGroup>
    );
  }
  else {
    return <span></span>
  }
};

export default DateRangeFilters;
