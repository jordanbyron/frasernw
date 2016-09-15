import React from "react";
import FilterGroup from "controllers/filter_group";
import { route, recordShownByRoute } from "controller_helpers/routing";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import FilterRadioButtons from "controllers/filter_radio_buttons";

const IssueSourceFilter = ({model, dispatch}) => {
  if (route === "/issues") {
    return(
      <FilterGroup
        title={"Issue Source"}
        isCollapsible={true}
        expansionControlKey={"issueSource"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterRadioButtons
          filterKey="issueSource"
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
    map(_.property("sourceKey")).
    pwPipe(_.flatten).
    pwPipe(_.uniq).
    map((key) => {
      return { key: key.toString(), label: model.app.issueSources[key] };
    }).pwPipe((options) => _.sortBy(options, _.property("key"))).
    pwPipe((options) => [{key: "0", label: "All"}].concat(options))
};

export default IssueSourceFilter;
