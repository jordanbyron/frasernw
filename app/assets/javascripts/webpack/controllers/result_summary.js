import React from "react";
import recordsToDisplay from "controller_helpers/records_to_display";
import { sidebarFilterKeys } from "controller_helpers/matches_sidebar_filters";
import filterSummaries from "controller_helpers/sidebar_filter_summaries";
import filters from "controller_helpers/sidebar_filters";
import { collectionShownFilterContextualizedLabel, collectionShownName }
  from "controller_helpers/collection_shown";
import { selectedTabKey } from "controller_helpers/tab_keys";
import { clearFilters } from "action_creators";
import { buttonIsh } from "stylesets";

const ResultSummary = ({model, dispatch}) => {
  if(shouldShow(model)){
    return(
      <div className={className(model)} style={{display: "block"}}>
        <span>{ `${label(model)}.   ` }</span>
        <ClearButton model={model} dispatch={dispatch}/>
      </div>
    );
  }
  else {
    return <noscript/>
  }
}

const ClearButton = ({model, dispatch}) => {
  if(anyFiltersActivated(model)){
    return(
      <a onClick={_.partial(clearFilters, dispatch, model)} style={buttonIsh}>
        Clear all filters.
      </a>
    );
  }
  else {
    return <noscript/>
  }
}

const anyFiltersActivated = (model) => {
  return _.values(_.get(model, ["ui", "tabs", selectedTabKey(model), "filterValues"], {})).
    pwPipe((overrides) => {
      return overrides.some((filterValue) => {
        return (_.isBoolean(filterValue) ||
          _.isString(filterValue) ||
          _.isNumber(filterValue) ||
          (_.isObject(filterValue) && _.any(_.values(filterValue))));
      })
    })
}

const shouldShow = (model) => {
  return activatedSummaries(model).length > 0;
}

const className = (model) => {
  if (recordsToDisplay(model).length > 0) {
    return "filter-phrase";
  } else {
    return "filter-phrase none";
  }
}

const label = (model) => {
  if (leadingFilterPredicates(model).length === 0 &&
    trailingFilterPredicates(model).length === 0) {

    return "";
  } else if (trailingFilterPredicates(model).length === 0) {
    return ([
      verb(model),
      leadingFilterPredicates(model),
      collectionShownFilterContextualizedLabel(model),
    ]).join(" ");
  } else {
    return ([
      verb(model),
      leadingFilterPredicates(model),
      collectionShownFilterContextualizedLabel(model),
      pronoun(model),
      trailingFilterPredicates(model)
    ]).join(" ");
  }
}

const activatedSummaries = (model) => {
  return _.pick(filterSummaries, sidebarFilterKeys(model)).
    pwPipe((filtersForPage) => {
      return _.filter(filtersForPage, (summary, key) => {
        if(summary.isActivated){
          return summary.isActivated(model);
        }
        else {
          return filters[key].isActivated(model);
        }
      })
    })
}

const trailingFilterPredicates = (model) => {
  return activatedSummaries(model).
    filter((summary) => summary.placement === "trailing").
    map((summary) => summary.label(model)).
    filter((segment) => segment.length > 0).
    join(" and ");
}

const leadingFilterPredicates = (model) => {
  return activatedSummaries(model).
    filter((summary) => summary.placement === "leading").
    map((summary) => summary.label(model)).
    filter((segment) => segment.length > 0).
    join(", ");
}

const verb = function(model) {
  if (recordsToDisplay(model).length > 0){
    return "Showing all";
  } else {
    return "There are no";
  }
}

const pronoun = function(model) {
  switch(collectionShownName(model)){
  case "clinics":
    return "that";
  case "specialists":
    return "who";
  default:
    return "that";
  }
}

export default ResultSummary;
