import React from "react";
import FilterGroup from "controllers/filter_group";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import FilterRadioButtons from "controllers/filter_radio_buttons";

const AssigneesFilter = ({model, dispatch}) => {
  if (matchedRoute(model) === "/issues") {
    return(
      <FilterGroup
        title={"Assignees"}
        isCollapsible={true}
        expansionControlKey={"assignees"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterRadioButtons
          filterKey="assignees"
          options={radioOptions(model)}
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

const radioOptions = (model) => {
  return recordsMaskingFilters(model).
    map(_.property("assigneesLabel")).
    pwPipe(_.flatten).
    pwPipe(_.uniq).
    filter((option) => option !== "").
    map((label) => {
      return { key: label, label: label };
    }).pwPipe((options) => _.sortBy(options, _.property("label"))).
    pwPipe((options) => {
      return [
        {key: "All", label: "All"},
        {key: "", label: "None"}
      ].concat(options)
    })
};

export default AssigneesFilter;
