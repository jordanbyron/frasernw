var objectAssign = require("object-assign");
var filters = require("./example_table/filters");
var filterVisibility = require("./example_table/filter_visibility");
var tableHeadings = require("./example_table/table_headings");
var records = require("./example_table/records");
var labels = require("./example_table/labels");
var sortConfig = require("./example_table/sort_config");

module.exports = function(state = {}, action) {
  console.log(action);
  return {
    tableHeadings: tableHeadings(state.tableHeadings, action),
    records: records(state.records, action),
    filters: filters(state.filters, action),
    filterVisibility: filterVisibility(state.filterVisibility, action),
    labels: labels(state.labels, action),
    sortConfig: sortConfig(state.sortConfig, action)
  };
}
