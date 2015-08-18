var objectAssign = require("object-assign");

var setAllOwnValues = function(obj, value) {
  for (var key in obj) {
    if (obj.hasOwnProperty(key)) {
      obj[key] = value;
    }
  }

  return obj;
}

var changeCitySelection = function(state, newValues) {
  var cityFilters = objectAssign(
    {},
    state.city
  )
  cityFilters = setAllOwnValues(cityFilters, newValues);

  return objectAssign(
    {},
    state,
    { city: cityFilters}
  );
}

var filters = function(state={city:{}}, action) {
  switch(action.type) {
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.filters
  case "FILTER_UPDATED":
    var newFilter = objectAssign(
      {},
      state[action.filterType],
      { [action.filterKey]: action.filterValue }
    );

    return objectAssign(
      {},
      state,
      { [action.filterType]: newFilter }
    );
  case "SELECT_ALL_CITIES":
    return changeCitySelection(state, true);
  case "DESELECT_ALL_CITIES":
    return changeCitySelection(state, false);
  default:
    return state;
  }
}

var filterVisibility = function(state={city: true}, action) {
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.filterVisibility;
  case "TOGGLE_FILTER_VISIBILITY":
    var newSetting = {};
    newSetting[action.filterKey] = !state[action.filterKey];

    return objectAssign(
      {},
      state,
      newSetting
    );
  default:
    return state;
  }
}

var tableHeadings = function(state = [], action) {
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.tableHeadings;
  default:
    return state;
  }
}

var records = function(state = [], action) {
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.records;
  default:
    return state;
  }
}

var labels = function(state={city: {}}, action) {
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.labels;
  default:
    return state;
  }
}

module.exports = function(state = {}, action) {
  console.log(action);
  return {
    tableHeadings: tableHeadings(state.tableHeadings, action),
    records: records(state.records, action),
    filters: filters(state.filters, action),
    filterVisibility: filterVisibility(state.filterVisibility, action),
    labels: labels(state.labels, action)
  };
}
