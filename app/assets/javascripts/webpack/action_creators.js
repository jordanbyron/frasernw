import * as FilterValues from "controller_helpers/filter_values";
import { matchedRoute } from "controller_helpers/routing";
import { selectedTabKey } from "controller_helpers/tab_keys";
import { cities as cityFilterSubkeys } from "controller_helpers/filter_subkeys";
import _ from "lodash";

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
  else if (matchedRoute(model) === "/reports/entity_page_views") {
    const requestParams = {
      month_key: FilterValues.month(model),
      division_id: FilterValues.divisionScope(model),
      record_type: FilterValues.entityType(model)
    }

    $.get(
      "/api/v1/reports/entity_page_views",
      requestParams
    ).done(function(data) {
      dispatch({
        type: "DATA_RECEIVED",
        recordsToDisplay: data.recordsToDisplay
      })
    });
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

export function tabClicked(dispatch, model, tabKey) {
  dispatch({
    type: "TAB_CLICKED",
    tabKey: tabKey
  })
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
  else if (event.target.type === "radio" && !isNaN(parseInt(event.target.value))) {
    return parseInt(event.target.value);
  }
  else {
    return event.target.value;
  }
};

export function changeFilter(dispatch, tabKey, filterKey, filterSubKey, event) {
  if(event.target.type !== "radio" || event.target.checked) {
    dispatch({
      type: "CHANGE_FILTER_VALUE",
      tabKey: tabKey,
      filterKey: filterKey,
      filterSubKey: filterSubKey,
      proposed: proposedValue(event)
    })
  }
}

export function changeFilterToValue(dispatch, tabKey, filterKey, filterSubKey, proposed) {
  dispatch({
    type: "CHANGE_FILTER_VALUE",
    tabKey: tabKey,
    filterKey: filterKey,
    filterSubKey: filterSubKey,
    proposed: proposed
  })
};

export function toggleUnfocusedProcedureVisibility(dispatch, proposed, tabKey) {
  dispatch({
    type: "TOGGLE_UNFOCUSED_PROCEDURE_VISIBILITY",
    tabKey: tabKey,
    proposed: proposed
  })
}

const proposedCityFilterValues = (activatedIds, model) => {
  return cityFilterSubkeys(model).map((id) => {
    return [ id, _.includes(activatedIds, id) ];
  }).pwPipe(_.zipObject)
};

export function updateCityFilters(dispatch, model, activatedIds) {
  dispatch({
    type: "UPDATE_CITY_FILTERS",
    tabKey: selectedTabKey(model),
    proposed: proposedCityFilterValues(activatedIds, model)
  });
}

export function parseLocation(dispatch){
  dispatch({
    type: "PARSE_LOCATION",
    location: window.location
  })
}

export const openFeedbackModal = (dispatch, id, itemType, modalTitle) => {
  dispatch({
    type: "OPEN_FEEDBACK_MODAL",
    data: {
      id: id,
      itemType: itemType,
      title: modalTitle
    }
  });
};

export function clearFilters(dispatch, model) {
  dispatch({
    type: "CLEAR_FILTERS",
    tabKey: selectedTabKey(model)
  });
}

export function toggleSpecializationFilter(dispatch, model, proposed) {
  dispatch({
    type: "TOGGLE_SPECIALIZATION_FILTER",
    tabKey: selectedTabKey(model),
    proposed: proposed
  });
}
