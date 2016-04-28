export function requestInitialData(model, dispatch){
  const requestParams = {
    divisionId: 5,
    startMonth: 201603,
    endMonth: 201603
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
