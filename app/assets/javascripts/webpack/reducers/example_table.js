var objectAssign = require("object-assign");

var initialState = {
  headings: ["one"],
  records: [],
  filters: {id: {}}
};

module.exports = function(state = initialState, action) {
  console.log(action);
  switch (action.type) {
  case "INITIALIZE_FROM_SERVER":
    return objectAssign({}, action.initialState);
  case "FILTER_UPDATED":
    var newFilter = {};
    newFilter[action.filterKey] = action.filterValue;

    var newIdFilters = objectAssign(
      {},
      state.filters.id,
      newFilter
    );

    return objectAssign({}, state, { filters: {id: newIdFilters } } );
  default:
    return state;
  }
}
