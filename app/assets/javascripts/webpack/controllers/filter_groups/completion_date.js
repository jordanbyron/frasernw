import React from "react";
import FilterGroup from "controllers/filter_group";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import FilterRadioButtons from "controllers/filter_radio_buttons";

const CompletionDateFilter = ({model, dispatch}) => {
  if (matchedRoute(model) === "/issues") {
    return(
      <FilterGroup
        title={"Estimated Completion Date"}
        isCollapsible={true}
        expansionControlKey={"completion"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterRadioButtons
          filterKey="completionDate"
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
    map(_.property("completionEstimateKey")).
    pwPipe(_.flatten).
    pwPipe(_.uniq).
    map((key) => {
      return { key: key, label: model.app.completionEstimateLabels[key] };
    }).pwPipe((options) => _.sortBy(options, _.property("key"))).
    pwPipe((options) => [{key: 0, label: "All"}].concat(options))
};

export default CompletionDateFilter;
