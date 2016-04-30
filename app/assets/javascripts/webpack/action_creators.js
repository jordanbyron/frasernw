import * as FilterValues from "controller_helpers/filter_values";

export function requestData(model, dispatch){
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
