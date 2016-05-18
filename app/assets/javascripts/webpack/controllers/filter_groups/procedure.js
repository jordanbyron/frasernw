import React from "react";
import FilterGroup from "component_helpers/filter_group";
import { recordShownByPage, matchedRoute } from "controller_helpers/routing";
import { selectedTabKey } from "controller_helpers/tab_keys";
import { toggleFilterGroupExpansion, toggleUnfocusedProcedureVisibility }
  from "action_creators";
import ProcedureCheckbox from "component_helpers/procedure_checkbox";
import _ from "lodash";
import { collectionShownName, scopedByRouteAndTab }
  from "controller_helpers/collection_shown";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import { changeFilter } from "action_creators"
import { procedure as procedureFilterValue } from "controller_helpers/filter_values";
import ExpandBox from "component_helpers/expand_box";

const ProcedureFilters = ({model, dispatch}) => {
  if (_.includes(ROUTES, matchedRoute(model)) && anyProcedureFilters(model)){
    return(
      <FilterGroup
        title={title(model)}
        isExpandable={true}
        isExpanded={isExpanded(model)}
        toggleExpansion={
          _.partial(
            toggleFilterGroupExpansion,
            dispatch,
            selectedTabKey(model),
            "procedures",
            !isExpanded(model)
          )
        }
      >
        <Focused model={model} dispatch={dispatch}/>
        <Unfocused model={model} dispatch={dispatch}/>
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
}

const isUnfocusedExpanded = (model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "showUnfocusedProcedures"],
    false
  )
};

const anyUnfocused = (model) => {
  return recordShownByPage(model).
    nestedProcedures.
    pwPipe(_.values).
    filter((procedure) => {
      return !procedure.focused &&
        !procedure.assumed[collectionShownName(model)] &&
        _.includes(procedureIdsMaskingFilters(model), procedure.id);
    }).pwPipe(_.any);
};

const Unfocused = ({model, dispatch}) => {
  if (matchedRoute(model) === "/specialties/:id" && anyUnfocused(model)) {
    return(
      <ExpandBox expanded={isUnfocusedExpanded(model)}
        handleToggle={
          _.partial(
            toggleUnfocusedProcedureVisibility,
            dispatch,
            !isUnfocusedExpanded(model),
            selectedTabKey(model)
          )
        }
      >
        {
          recordShownByPage(model).
            nestedProcedures.
            pwPipe(_.values).
            filter((procedure) => !procedure.focused).
            pwPipe((procedures) => {
              return procedureCheckboxesFromNested(
                procedures,
                0,
                model,
                dispatch
              );
            })
        }
      </ExpandBox>
    )
  }
  else {
    return <span></span>;
  }
}

const anyProcedureFilters = (model) => {
  if (matchedRoute(model) === "/specialties/:id"){
    return recordShownByPage(model).
        nestedProcedures.
        pwPipe(_.values).
        filter((procedure) => {
          return !procedure.assumed[collectionShownName(model)] &&
            _.includes(procedureIdsMaskingFilters(model), procedure.id)
        }).pwPipe(_.any);
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id"){
    return _.any(recordShownByPage(model).childrenProcedureIds);
  }
}

const Focused = ({model, dispatch}) => {
  if (matchedRoute(model) === "/areas_of_practice/:id"){
    return(
      <div>
        {
          recordShownByPage(model).
            childrenProcedureIds.
            map((id) => {

              return(
                <ProcedureCheckbox
                  onChange={
                    _.partial(
                      changeFilter,
                      dispatch,
                      selectedTabKey(model),
                      "procedures",
                      id
                    )
                  }
                  key={id}
                  label={model.app.procedures[id].name}
                  checked={procedureFilterValue(model, id)}
                  level={0}
                />
              )
            }).pwPipe(checkBoxes => {
              return _.sortBy(checkBoxes, _.property("props.label"));
            })
        }
      </div>
    );
  }
  else if (matchedRoute(model) === "/specialties/:id"){
    return(
      <div>
        {
          recordShownByPage(model).
            nestedProcedures.
            pwPipe(_.values).
            filter(_.property("focused")).
            pwPipe((focusedProcedures) => {
              return procedureCheckboxesFromNested(
                focusedProcedures,
                0,
                model,
                dispatch
              );
            })
        }
      </div>
    )
  }
}

const procedureCheckboxesFromNested = (nestedProcedures, level, model, dispatch) => {
  return _.values(nestedProcedures).
    filter((procedure) => {
      return !procedure.assumed[collectionShownName(model)] &&
        _.includes(procedureIdsMaskingFilters(model), procedure.id);
    }).map((procedure) => {
      return(
        <ProcedureCheckbox
          onChange={
            _.partial(
              changeFilter,
              dispatch,
              selectedTabKey(model),
              "procedures",
              procedure.id
            )
          }
          key={procedure.id}
          label={model.app.procedures[procedure.id].name}
          checked={procedureFilterValue(model, procedure.id)}
          level={level}
        >
          { procedureCheckboxesFromNested(procedure.children, (level + 1), model, dispatch) }
        </ProcedureCheckbox>
      );
    }).pwPipe((checkBoxes) => _.sortBy(checkBoxes, _.property("props.label")))
};

const procedureIdsMaskingFilters = (model) => {
  return recordsMaskingFilters(model).
    map(_.property("procedureIds")).
    pwPipe(_.flatten).
    pwPipe(_.uniq);
};

const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];

const isExpanded = (model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "isFilterGroupExpanded", "procedures"],
    true
  );
};

const title = (model) => {
  if (matchedRoute(model) === "/specialties/:id"){
    return "Accepts referrals for";
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id") {
    return "Sub-Areas of Practice";
  }
};

export default ProcedureFilters;
