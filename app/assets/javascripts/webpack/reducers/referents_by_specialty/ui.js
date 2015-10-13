var hasBeenInitialized = require("../has_been_initialized");
var filterValues = require("../filter_table/filter_values");

module.exports = function(state = {}, action) {
  return {
    hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
    filterValues: filterValues(state.filterValues, action)
  };
}
