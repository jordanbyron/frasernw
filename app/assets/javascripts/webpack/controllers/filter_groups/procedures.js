import React from "react";
import FilterGroup from "controllers/filter_group";
import { recordShownByRoute, route } from "controller_helpers/routing";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import { toggleUnfocusedProcedureVisibility }
  from "action_creators";
import _ from "lodash";
import { collectionShownName } from "controller_helpers/collection_shown";
import ExpandingContainer from "component_helpers/expanding_container";
import { procedures as subkeys } from "controller_helpers/filter_subkeys";
import { buttonIsh } from "stylesets";
import FilterCheckbox from "controllers/filter_checkbox";
import NestedFilterCheckbox from "controllers/nested_filter_checkbox";

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
  return _.includes(ROUTES, route) &&
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
  return recordShownByRoute(model).
    nestedProcedures.
    pwPipe(_.values).
    filter((procedure) => {
      return !procedure.focused &&
        _.includes(subkeys(model), procedure.id)
    }).pwPipe(_.any);
};

const Focused = ({model, dispatch}) => {
  if (route === "/areas_of_practice/:id"){
    return(
      <div>
        {
          subkeys(model).
            map((id) => {
              return(
                <FilterCheckbox
                  model={model}
                  dispatch={dispatch}
                  filterKey="procedures"
                  key={id}
                  label={
                    <ProcedureCheckboxLabel
                      labelText={model.app.procedures[id].name}
                      customWaittime={
                        model.
                        app.
                        procedures[id].
                        customWaittime[collectionShownName(model)]
                      }
                    />
                  }
                  filterSubkey={id}
                />
              );
            }).pwPipe(checkBoxes => {
              return _.sortBy(
                checkBoxes,
                _.property("props.label.props.labelText")
              );
            })
        }
      </div>
    );
  }
  else if (route === "/specialties/:id"){
    return(
      <div>
        {
          recordShownByRoute(model).
            nestedProcedures.
            pwPipe(_.values).
            filter(_.property("focused")).
            pwPipe((focusedProcedures) => {
              return procedureCheckboxesFromNested(
                focusedProcedures,
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
  if (route === "/specialties/:id" && anyUnfocused(model)) {
    return(
      <div>
        <a onClick={
            _.partial(
              toggleUnfocusedProcedureVisibility,
              dispatch,
              !isUnfocusedExpanded(model),
              selectedTabKey(model)
            )
          }
          style={buttonIsh}
        >{ unfocusedToggleText(isUnfocusedExpanded(model)) }</a>
        <ExpandingContainer expanded={isUnfocusedExpanded(model)}>
          {
            recordShownByRoute(model).
              nestedProcedures.
              pwPipe(_.values).
              filter((procedure) => !procedure.focused).
              pwPipe((procedures) => {
                return procedureCheckboxesFromNested(
                  procedures,
                  model,
                  dispatch
                );
              })
          }
        </ExpandingContainer>
      </div>
    )
  }
  else {
    return <span></span>;
  }
}

const unfocusedToggleText = (isCurrentlyExpanded) => {
  if (isCurrentlyExpanded) {
    return "Less...";
  } else {
    return "More...";
  }
}

const procedureCheckboxesFromNested = (nestedProcedures, model, dispatch) => {
  return _.values(nestedProcedures).
    filter((procedure) => {
      return _.includes(subkeys(model), procedure.id);
    }).map((procedure) => {
      return(
        <NestedFilterCheckbox
          model={model}
          dispatch={dispatch}
          key={procedure.id}
          filterKey="procedures"
          label={
            <ProcedureCheckboxLabel
              labelText={model.app.procedures[procedure.id].name}
              customWaittime={procedure.customWaittime[collectionShownName(model)]}
            />
          }
          filterSubkey={procedure.id}
        >
          { procedureCheckboxesFromNested(procedure.children, model, dispatch) }
        </NestedFilterCheckbox>
      );
    }).pwPipe((checkBoxes) => {
      return _.sortBy(checkBoxes, _.property("props.label.props.labelText"))
    })
};

const ProcedureCheckboxLabel = ({labelText, customWaittime}) => {
  if (customWaittime) {
    return(
      <span>
        <span>{labelText}</span>
        <i className="icon-link" style={{marginLeft: "5px"}}/>
      </span>
    );
  }
  else {
    return (<span>{labelText}</span>)
  }
}

const title = (model) => {
  if (route === "/specialties/:id"){
    return "Accepts referrals for";
  }
  else if (route === "/areas_of_practice/:id") {
    return "Sub-Areas of Practice";
  }
};

export default ProcedureFilters;
