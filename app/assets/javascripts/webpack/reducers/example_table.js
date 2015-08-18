var objectAssign = require("object-assign");

var initialState = {
  tableHeadings: [],
  records: [],
  filters: {id: {}},
  filterVisibility: {id: true}
};

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
  case "FILTER_UPDATED":
    var newFilter = {};
    newFilter[action.filterKey] = action.filterValue;

    var newIdFilters = objectAssign(
      {},
      state.filters.id,
      newFilter
    );

    var newFilters = {
      filters: {
        id: newIdFilters
      }
    }

    return objectAssign({}, state, { filters: {id: newIdFilters } } );
  default:
    return state;
  }
}
