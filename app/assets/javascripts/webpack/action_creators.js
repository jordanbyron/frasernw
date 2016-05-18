import * as FilterValues from "controller_helpers/filter_values";
import { matchedRoute } from "controller_helpers/routing";

export function requestDynamicData(model, dispatch){
  if(matchedRoute(model) === "/reports/pageviews_by_user"){
    const requestParams = {
      divisionId: FilterValues.divisionScope(model),
      startMonth: FilterValues.startMonth(model),
      endMonth: FilterValues.endMonth(model)
    }

    $.get(
      "/api/v1/reports/pageviews_by_user",
      { data: requestParams }
    ).done(function(data) {
      dispatch({
        type: "DATA_RECEIVED",
        recordsToDisplay: data.recordsToDisplay
      })
    })
  }
}

export function changeFilterValue(dispatch, filterKey, newValue) {
  dispatch({
    type: "CHANGE_FILTER_VALUE",
    filterKey: filterKey,
    newValue: newValue
  });
}

export function parseRenderedData(dispatch) {
  dispatch({
    type: "PARSE_RENDERED_DATA",
    data: window.pathways.dataForReact
  });
};

export function sortByHeading(dispatch, key, currentKey) {
  dispatch({
    type: "SORT_BY_HEADING",
    currentKey: currentKey,
    key: key
  })
}

export function locationChanged(dispatch, newLocation) {
  dispatch({
    type: "LOCATION_CHANGED",
    location: newLocation
  });
}

export function integrateLocalStorageData(dispatch, data) {
  dispatch({
    type: "INTEGRATE_LOCALSTORAGE_DATA",
    data: data
  });
}

export function toggleBreadcrumbDropdown(dispatch, isCurrentlyOpen){
  dispatch({
    type: "TOGGLE_BREADCRUMB_DROPDOWN",
    newState: !isCurrentlyOpen
  })
};

export function changeRoute(dispatch, route) {
  dispatch({
    type: "CHANGE_ROUTE",
    route: route
  })
}

export function tabClicked(dispatch, model, tabKey) {
  changeRoute(
    dispatch,
    `${model.ui.location.pathname}?tabKey=${tabKey}`
  );
}

export function selectReducedView(dispatch, newView) {
  dispatch({
    type: "SELECT_REDUCED_VIEW",
    newView: newView
  })
}

export function toggleFilterGroupExpansion(dispatch, tabKey, filterGroupKey, proposed){
  dispatch({
    type: "TOGGLE_FILTER_GROUP_EXPANSION",
    tabKey: tabKey,
    filterGroupKey: filterGroupKey,
    proposed: proposed
  })
}

const proposedValue = (event) => {
  if (event.target.type === "checkbox"){
    return event.target.checked;
  }
}

export function changeFilter(dispatch, tabKey, filterKey, filterSubKey, event) {
  dispatch({
    type: "CHANGE_FILTER_VALUE",
    tabKey: tabKey,
    filterKey: filterKey,
    filterSubKey: filterSubKey,
    proposed: proposedValue(event)
  })
}
