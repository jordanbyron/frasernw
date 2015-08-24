var React = require("react");
var Table = require("./table");
var SidebarLayout = require("./sidebar_layout");
var Filters = require("./filters");
var sortBy = require("lodash/collection/sortBy");
var objectAssign = require("object-assign");
var filterComponents = {
  city: require("./city_filter"),
  procedureSpecializations: require("./procedure_specializations_filter"),
  referrals: require("./referrals_filter"),
  sex: require("./sex_filter"),
  schedule: require("./schedule_filter")
}
var rowFilters = require("../datatable_support/filters");
var rowGenerators = require("../datatable_support/row_generators");
var sortFunctions = require("../datatable_support/sort_functions");


module.exports = React.createClass({
  toggleFilterVisibility: function(key) {
    return this.props.dispatch({
      type: "TOGGLE_FILTER_VISIBILITY",
      filterKey: key
    });
  },
  updateFilter: function(filterType, update){
    return this.props.dispatch({
      type: "FILTER_UPDATED",
      filterType: filterType,
      update: update
    });
  },
  handleHeaderClick: function(key) {
    return () => {
      return this.props.dispatch({
        type: "HEADER_CLICK",
        headerKey: key
      });
    };
  },
  filterFunction: function() {
    return rowFilters[this.props.filterFunction];
  },
  sortFunction: function() {
    return sortFunctions[this.props.sortFunction];
  },
  rowGenerator: function() {
    return rowGenerators[this.props.rowGenerator];
  },
  labels: function() {
    return objectAssign(
      {},
      this.props.labels,
      this.props.globalData.labels
    );
  },
  bodyRows: function() {
    var unsorted = this.props.records
      .filter((row) => {
        return this.filterFunction()(row, this.props.filterValues);
      }).map((row) => {
        return this.rowGenerator()(row, this.labels())
      });

    var sorted = sortBy(
      unsorted,
      this.sortFunction()(this.props.sortConfig)
    );

    if (this.props.sortConfig.order == "DESC"){
      return sorted.reverse();
    } else {
      return sorted;
    }
  },
  table: function() {
    return (
      <Table
        headings={this.props.tableHeadings}
        bodyRows={this.bodyRows()}
        sortConfig={this.props.sortConfig}
        handleHeaderClick={this.handleHeaderClick}
      />
    );
  },
  labelsForFilter: function(filterKey) {
    return this.props.labels[filterKey] || this.props.globalData.labels[filterKey];
  },
  sidebar: function() {
    return (
      <Filters title={this.props.labels.filterSection}>
        {
          this.props.filterComponents.map((filterKey, index)=>{
            return React.createElement(
              filterComponents[filterKey],
              {
                filters: this.props.filterValues[filterKey],
                labels: this.labelsForFilter(filterKey),
                arrangement: this.props.filterArrangements[filterKey],
                visible: this.props.filterVisibility[filterKey],
                toggleVisibility: this.toggleFilterVisibility,
                updateFilter: this.updateFilter,
                key: index
              }
            )
          })
        }
      </Filters>
    );
  },
  render: function() {
    return (
      <SidebarLayout
        main={this.table()}
        sidebar={this.sidebar()}
      />
    );
  }
});
