var objectAssign = require("object-assign");
var filterValues = require("./data_table/filter_values");
var filterVisibility = require("./data_table/filter_visibility");
var sortConfig = require("./data_table/sort_config");

module.exports = function(state = {}, action) {
  return objectAssign(
    {},
    state,
    {
      filterValues: filterValues(state.filterValues, action),
      filterVisibility: filterVisibility(state.filterVisibility, action),
      sortConfig: sortConfig(state.sortConfig, action)
    }
  );
}
