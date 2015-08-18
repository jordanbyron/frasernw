var objectAssign = require("object-assign");

var initialState = {
  tableHeadings: [],
  records: [],
  filters: {city: {}},
  filterVisibility: {city: true},
  cityIndex: {}
};

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
    state.filters.city
  )
  cityFilters = setAllOwnValues(cityFilters, newValues);

  var newFilters = objectAssign(
    {},
    state.filters,
    { city: cityFilters}
  )

  return objectAssign({}, state, { filters: newFilters} );
}

module.exports = function(state = initialState, action) {
  console.log(action);
  switch (action.type) {
  case "INITIALIZE_FROM_SERVER":
    return objectAssign({}, action.initialState);
  case "TOGGLE_FILTER_VISIBILITY":
    var newSetting = {};
    newSetting[action.filterKey] = !state.filterVisibility[action.filterKey];

    var newFilterVisibility = objectAssign(
      {},
      state.filterVisibility,
      newSetting
    )

    return objectAssign({}, state, {filterVisibility: newFilterVisibility});
  case "SELECT_ALL_CITIES":
    return changeCitySelection(state, true);
  case "DESELECT_ALL_CITIES":
    return changeCitySelection(state, false);
  case "FILTER_UPDATED":
    var newFilter = objectAssign(
      {},
      state.filters[action.filterType],
      { [action.filterKey]: action.filterValue }
    );

    var newFilters = objectAssign(
      {},
      state.filters,
      { [action.filterType]: newFilter }
    );
    console.log(newFilters);

    return objectAssign({}, state, { filters: newFilters } );
  default:
    return state;
  }
}
