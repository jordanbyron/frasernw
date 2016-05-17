import React from "react";
import FilterGroup from "component_helpers/filter_group";
import { matchedRoute } from "controller_helpers/routing";
import { selectedPanelKey } from "controller_helpers/panel_keys";
import { toggleFilterGroupExpansion } from "action_creators";
import _ from "lodash";

const ProcedureFilters = ({model, dispatch}) => {
  if (_.includes(ROUTES, matchedRoute(model))){
    return(
      <FilterGroup
        title={title(model)}
        isExpandable={true}
        isExpanded={isExpanded(model)}
        toggleExpansion={
          _.partial(
            toggleFilterGroupExpansion,
            dispatch,
            selectedPanelKey(model),
            "procedures",
            !isExpanded(model)
          )
        }
      >
        <Focused model={model} dispatch={dispatch}/>
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
}

const Focused = ({model, dispatch}) => {
  if (matchedRoute(model) === "/areas_of_practice/:id"){
    return(
      <div>
        {
          recordShown(model).
            childrenProcedureIds.
            map((id) => {
              return(
                <ProcedureCheckbox
                  onClick={}
                  label={label}
                  checked={}
                  level={}
                />
              )
            }).pwPipe(checkboxes => {
              return _.sortBy(checkBoxes, (box) => box.props.label)
            })
        }
      </div>
    );
  }
  else if (matchedRoute(model) === "/specialties/:id"){
    return(
      <div>
        {
          _.pick(
            recordShown(model).nestedProcedures,
            _.property("focused")
          ).pwPipe(procedureCheckboxesFromNested)
        }
      </div>
    )
  }
}

const procedureCheckboxesFromNested = (nestedProcedures) => {
  return _.values(nestedProcedures).
    filter((procedure) => {
      return !procedure.assumed[collectionShown(model)] &&
        _.includes(filterMaskingSetProcedureIds(model), procedure.id)
    }).map((procedure) => {
      return(
        <ProcedureCheckbox
          onClick={}
          label={label}
          checked={}
          level={}
        />
      );
    }).pwPipe((boxes) => _.sortBy(boxes, _.property("props.label")))
};

const filteringByProcedureIds = (

const filterMaskingSet = (model) => {

}

const filterMaskingSetProcedureIds = (model) => {
  return filterMaskingSet(model).
    map(_.property("procedureIds")).
    pwPipe(_.flatten).
    pwPipe(_.uniq);
}

const ProcedureCheckbox = ({}) => {
  return <div></div>;
}

const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];

const isExpanded = (model) => {
  return _.get(
    model,
    ["ui", "panels", selectedPanelKey(model), "isFilterGroupExpanded", "procedures"],
    true
  );
}

const title = (model) => {
  if (matchedRoute(model) === "/specialties/:id"){
    return "Accepts referrals for";
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id") {
    return "Sub-Areas of Practice";
  }
}

export default ProcedureFilters;
