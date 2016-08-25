import React from "react";
import FilterGroup from "controllers/filter_group";
import { matchedRoute, recordShownByRoute } from "controller_helpers/routing";
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
    map(_.property("assigneeIds")).
    filter((ids) => !_.isEqual(ids, [])).
    pwPipe((ids) => {
      return ids.reduce((accumulator, value) => {
        const existingMember = _.find(
          accumulator,
          (accumulatorItem) => _.isEqual(accumulatorItem, value)
        )

        if (!existingMember){
          return accumulator.concat([value]);
        }
        else {
          return accumulator;
        }
      }, []);
    }).map((ids) => {
      return {
        key: ids.join(","),
        label: ids.map((id) => firstName(id, model)).join(" & ")
      };
    }).
    pwPipe((options) => _.sortBy(options, _.property("label"))).
    pwPipe((options) => {
      return [
        { key: "All", label: "All" },
        { key: "", label: "None" }
      ].concat(options)
    })
};

const firstName = (assigneeId, model) => {
  return model.app.assignees[assigneeId].name.match(/[^\s]+/);
}

export default AssigneesFilter;
