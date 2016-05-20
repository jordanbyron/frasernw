import React from "react";
import FilterGroup from "controllers/filter_group";
import { recordShownByPage, matchedRoute } from "controller_helpers/routing";
import { selectedTabKey } from "controller_helpers/tab_keys";
import { toggleUnfocusedProcedureVisibility }
  from "action_creators";
import ProcedureCheckbox from "component_helpers/procedure_checkbox";
import _ from "lodash";
import { collectionShownName, scopedByRouteAndTab }
  from "controller_helpers/collection_shown";
import { changeFilter } from "action_creators"
import { procedure as procedureFilterValue } from "controller_helpers/filter_values";
import ExpandBox from "component_helpers/expand_box";
import { procedures as subkeys } from "controller_helpers/filter_subkeys";

const ProcedureFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={title(model)}
        isCollapsible={true}
        defaultIsExpanded={true}
        expansionControlKey={"procedures"}
        model={model}
        dispatch={dispatch}
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

const shouldShow = (model) => {
  return _.includes(ROUTES, matchedRoute(model)) &&
    _.includes(COLLECTIONS, collectionShownName(model)) &&
    _.any(subkeys(model));
}
const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];
const COLLECTIONS = [
  "specialists",
  "clinics"
]

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
        _.includes(subkeys(model), procedure.id)
    }).pwPipe(_.any);
};

const Focused = ({model, dispatch}) => {
  if (matchedRoute(model) === "/areas_of_practice/:id"){
    return(
      <div>
        {
          subkeys(model).
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
                  customWaittime={
                    model.
                      app.
                      procedures[id].
                      customWaittime[collectionShownName(model)]
                  }
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

const procedureCheckboxesFromNested = (nestedProcedures, level, model, dispatch) => {
  return _.values(nestedProcedures).
    filter((procedure) => {
      return _.includes(subkeys(model), procedure.id);
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
          customWaittime={procedure.customWaittime[collectionShownName(model)]}
        >
          { procedureCheckboxesFromNested(procedure.children, (level + 1), model, dispatch) }
        </ProcedureCheckbox>
      );
    }).pwPipe((checkBoxes) => _.sortBy(checkBoxes, _.property("props.label")))
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
