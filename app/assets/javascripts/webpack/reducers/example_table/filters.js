var setAllOwnValues = require("../../utils.js").setAllOwnValues;
var objectAssign = require("object-assign");

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

module.exports = function(state={city:{}}, action) {
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
