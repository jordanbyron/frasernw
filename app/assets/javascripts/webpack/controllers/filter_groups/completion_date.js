import React from "react";
import FilterGroup from "controllers/filter_group";
import { route, recordShownByRoute } from "controller_helpers/routing";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import FilterCheckbox from "controllers/filter_checkbox";

const CompletionDateFilter = ({model, dispatch}) => {
  if (route === "/issues") {
    return(
      <FilterGroup
        title={"Targeted Completion Date"}
        isCollapsible={true}
        expansionControlKey={"completion"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterCheckbox
          label="This Weekend"
          filterKey="completeThisWeekend"
          model={model}
          dispatch={dispatch}
        />
        <FilterCheckbox
          label="Next User Group Meeting"
          filterKey="completeNextMeeting"
          model={model}
          dispatch={dispatch}
        />
        <FilterCheckbox
          label="Not Targeted"
          filterKey="notTargeted"
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

export default CompletionDateFilter;
