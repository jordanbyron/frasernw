var hasBeenInitialized = require("../has_been_initialized");
var filterValues = require("../filter_table/filter_values");
var filterVisibility = require("../filter_table/filter_group_visibility");

module.exports = function(state = {}, action) {
  return {
    hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
    filterValues: filterValues(state.filterValues, action),
    filterVisibility: filterVisibility(state.filterVisibility, action)
  };
}