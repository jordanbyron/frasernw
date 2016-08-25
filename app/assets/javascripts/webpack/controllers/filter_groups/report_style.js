import React from "react";
import FilterGroup from "controllers/filter_group";
import { matchedRoute, recordShownByRoute } from "controller_helpers/routing";
import FilterRadioButtons from "controllers/filter_radio_buttons";

const ReportStyleFilters = ({model, dispatch}) => {
  if (matchedRoute(model) === "/reports/referents_by_specialty") {
    return(
      <FilterGroup
        title={"Report Style"}
        isCollapsible={true}
        expansionControlKey={"reportStyle"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterRadioButtons
          filterKey="reportStyle"
          options={OPTIONS}
          model={model}
          dispatch={dispatch}
        />
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
};

const OPTIONS = [
  {
    key: "expanded",
    label: "Expanded"
  },
  {
    key: "summary",
    label: "Summary"
  }
]

export default ReportStyleFilters;
