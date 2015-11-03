var hasBeenInitialized = require("../has_been_initialized");
var filterValues = require("../filter_table/filter_values");
var filterVisibility = require("../filter_table/filter_group_visibility");
var rows = function(state, action) {
  switch(action.type) {
  case "UPDATE_ROWS":
    return action.rows;
  default:
    return state;
  }
};
var isTableLoading = function(state, action) {
  switch(action.type) {
  case "MAKE_INITIAL_API_QUERY":
    return true;
  case "UPDATE_ROWS":
    return false;
  case "ASYNC_FILTER_UPDATE":
    return true;
  default:
    return state;
  }
};

module.exports = function(state = {}, action) {
  return {
    hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
    filterValues: filterValues(state.filterValues, action),
    filterVisibility: filterVisibility(state.filterVisibility, action),
    rows: rows(state.rows, action),
    isTableLoading: isTableLoading(state.isTableLoading, action)
  };
}
