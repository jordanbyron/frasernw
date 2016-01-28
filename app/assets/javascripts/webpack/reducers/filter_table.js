var _ = require("lodash");
var sortConfig = require("reducers/filter_table/sort_config");
var filterGroupVisibility = require("./filter_table/filter_group_visibility");
var filterValues = require("./filter_table/filter_values");
import reducedView from "reducers/filter_table/reduced_view";

var filterExpansion = function(state, action) {
  switch(action.type){
  case "TOGGLE_FILTER_EXPANSION":
    return _.assign(
      {},
      state,
      { [action.filterType] : action.value }
    );
  default:
    return state;
  }
}

module.exports = function(state = {}, action) {
  switch(action.type) {
  default:
    return _.assign(
      {},
      state,
      {
        sortConfig: sortConfig(state.sortConfig, action),
        filterGroupVisibility: filterGroupVisibility(state.filterGroupVisibility, action),
        filterValues: filterValues(state.filterValues, action),
        filterExpansion: filterExpansion(state.filterExpansion, action),
        reducedView: reducedView(state.reducedView, action)
      }
    );
  }
}
