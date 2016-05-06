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

export function locationChanged(dispatch, locationChanged) {
  dispatch({
    type: "LOCATION_CHANGED",
    location: location
  });
}

export function integrateLocalStorageData(dispatch, data) {
  dispatch({
    type: "INTEGRATE_LOCALSTORAGE_DATA",
    data: data
  });
}
